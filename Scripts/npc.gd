extends CharacterBody3D

signal game_over(reason: String)

@onready var nav_agent = $NavigationAgent3D
@onready var interact_label = $InteractLabel
@onready var anim_player = $girlfriend/AnimationPlayer

# === THÊM: tham chiếu tới DialogueUI ===
# Gán node DialogueUI vào đây trong Inspector, hoặc dùng path nếu biết trước
@export var dialogue_ui: CanvasLayer
@export var intro_dialogue_key: String = "greet"
@export var intro_delay: float = 2.0


var SPEED = 3.0
var FOLLOW_DISTANCE = 3.0
var RESUME_DISTANCE = 4.5
var MAX_DISTANCE = 8.0
var TIME_LIMIT = 3.0
var time_too_far = 0.0

var LOVE_TIMER_LIMIT = 30.0
var love_timer = 0.0
var INTERACT_DISTANCE = 2.5

var player: Node3D

# Theo dõi hội thoại cuối cùng để tránh lặp liên tiếp
var _last_dialogue_key := ""

func _ready():
	floor_max_angle = deg_to_rad(60)
	floor_snap_length = 0.3
	player = get_tree().get_first_node_in_group("player")
	if interact_label:
		interact_label.visible = false
	anim_player.play("idle")

	# Tự nói khi bắt đầu
	await get_tree().create_timer(intro_delay).timeout
	if dialogue_ui:
		dialogue_ui.show_dialogue(intro_dialogue_key)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	_check_distance(delta)
	_follow_player()
	_check_interact()
	_check_love_timer(delta)
	_update_interact_label()
	move_and_slide()

func _follow_player():
	if not player:
		return

	var dist_to_player = global_transform.origin.distance_to(player.global_transform.origin)

	if dist_to_player <= FOLLOW_DISTANCE:
		velocity.x = 0
		velocity.z = 0
		anim_player.play("idle")
		return

	if dist_to_player > RESUME_DISTANCE:
		nav_agent.set_target_position(player.global_transform.origin)

	if nav_agent.is_navigation_finished():
		velocity.x = 0
		velocity.z = 0
		anim_player.play("idle")
		return

	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_transform.origin).normalized()
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	anim_player.play("walk")

	if direction.length() > 0.1:
		var angle = atan2(-direction.x, -direction.z)
		rotation.y = angle

func _check_distance(delta):
	if not player:
		return
	var dist = global_transform.origin.distance_to(player.global_transform.origin)
	if dist > MAX_DISTANCE:
		time_too_far += delta
		if time_too_far >= TIME_LIMIT:
			_game_over("npc_too_far")
	else:
		time_too_far = 0.0

func _check_interact():
	if not player:
		return
	if not Input.is_action_just_pressed("interact"):
		return
	var dist = global_transform.origin.distance_to(player.global_transform.origin)
	if dist <= INTERACT_DISTANCE:
		love_timer = 0.0
	

func _trigger_dialogue():
	if not dialogue_ui:
		push_warning("NPC: dialogue_ui chưa được gán!")
		return

	# Chọn key ngẫu nhiên, tránh lặp lại key vừa dùng
	var keys = ["greet", "love", "idle_chat", "jealous"]
	keys.erase(_last_dialogue_key)
	var key = keys.pick_random()
	_last_dialogue_key = key
	dialogue_ui.show_dialogue(key)

func _check_love_timer(delta):
	love_timer += delta
	if love_timer >= LOVE_TIMER_LIMIT:
		_game_over("no_love")

func _update_interact_label():
	if not player or not interact_label:
		return
	var dist = global_transform.origin.distance_to(player.global_transform.origin)
	interact_label.visible = dist <= INTERACT_DISTANCE

func _game_over(reason: String):
	emit_signal("game_over", reason)
