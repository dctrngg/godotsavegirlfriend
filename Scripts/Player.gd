extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.8
const SENSITIVITY = 0.002
const MAX_STARE_DISTANCE = 5.0

const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

var gravity = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var ray = $Head/Camera3D/RayCast3D
var current_target = null

var is_dead := false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if is_dead:
		return
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))


func _physics_process(delta):
	if is_dead:
		return

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	move_and_slide()
	_check_stare()

func _check_stare():
	if not ray or not ray.is_colliding():
		if current_target:
			_cleanup_current_target()
		return
	
	var hit = ray.get_collider()
	var dist = camera.global_position.distance_to(ray.get_collision_point())
	
	if dist > MAX_STARE_DISTANCE:
		if current_target:
			_cleanup_current_target()
		return

	if hit and hit.has_method("start_watching"):
		if current_target != hit:
			if current_target:
				_cleanup_current_target()
			
			current_target = hit
			current_target.start_watching()
			
			# KẾT NỐI TÍN HIỆU: Lắng nghe sự kiện game_over từ người lạ này
			if current_target.has_signal("game_over") and not current_target.game_over.is_connected(_on_npc_game_over):
				current_target.game_over.connect(_on_npc_game_over)
	else:
		if current_target:
			_cleanup_current_target()

# Hàm bổ trợ để dọn dẹp kết nối cũ khi quay xe nhìn đi chỗ khác
func _cleanup_current_target():
	if current_target:
		if current_target.game_over.is_connected(_on_npc_game_over):
			current_target.game_over.disconnect(_on_npc_game_over)
		current_target.stop_watching()
		current_target = null

# Hàm xử lý khi NPC phát tín hiệu Game Over
func _on_npc_game_over(reason: String):
	if is_dead:
		return
		
	# 1. Gọi hàm hiệu ứng xoay camera về phía NPC tội đồ (chạy trong 1.5 giây)
	start_death_camera(current_target.global_position, func():
		# 2. Callback này sẽ TỰ ĐỘNG CHẠY sau khi camera đã xoay xong xuôi!
		# Tìm Node UI Game Over trong Scene Tree để kích hoạt popup
		var game_over_ui = get_tree().root.find_child("GameOverUI", true, false)
		
		if game_over_ui:
			game_over_ui.show_popup(reason)
		else:
			print("LỖI: Không tìm thấy node mang tên 'GameOverUI' trong Scene Tree!")
	)
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos


func start_death_camera(target_pos: Vector3, on_complete: Callable, duration: float = 1.5):
	# Set PROCESS_MODE_ALWAYS để tween tiếp tục chạy dù game bị pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	is_dead = true
	velocity = Vector3.ZERO

	var to_target = target_pos - camera.global_transform.origin
	var to_local = global_transform.basis.inverse() * to_target

	var target_raw = atan2(-to_local.x, -to_local.z)
	var cur = fmod(head.rotation.y, TAU)
	if cur > PI: cur -= TAU
	elif cur < -PI: cur += TAU

	var d = fmod(target_raw - cur, TAU)
	if d > PI: d -= TAU
	elif d < -PI: d += TAU

	var target_head_y = head.rotation.y + d

	var dh = Vector2(to_target.x, to_target.z).length()
	var target_cam_x = clamp(atan2(to_target.y, dh), deg_to_rad(-80), deg_to_rad(60))

	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(head, "rotation:y", target_head_y, duration)
	tween.tween_property(camera, "rotation:x", target_cam_x, duration)
	tween.chain().tween_callback(on_complete)
