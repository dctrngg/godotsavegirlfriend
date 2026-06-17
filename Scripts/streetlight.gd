extends RigidBody3D

signal game_over(reason: String)

var triggered = false
var fall_target: Node3D = null
var has_hit = false

@export var fall_torque = 500.0

func _ready():
	freeze = true

	if not $Area3D.body_entered.is_connected(_on_area_3d_body_entered):
		$Area3D.body_entered.connect(_on_area_3d_body_entered)

func _on_area_3d_body_entered(body):
	if triggered:
		return
	if body.is_in_group("player") or body.is_in_group("girlfriend"):
		triggered = true
		fall_target = body
		_fall_towards(body.global_position)
func _fall_towards(target_pos: Vector3):
	freeze = false
	var direction = (target_pos - global_position).normalized()
	direction.y = 0
	var torque_axis = Vector3.UP.cross(direction)
	print("Torque axis: ", torque_axis)
	print("Fall torque: ", fall_torque)
	apply_torque(torque_axis * fall_torque)

func _physics_process(delta):
	if not triggered or fall_target == null or has_hit:
		return
	var dist = global_position.distance_to(fall_target.global_position)
	if dist < 3.0:
		has_hit = true
		var reason = ""
		if fall_target.is_in_group("player"):
			reason = "hit_by_streetlight"
		elif fall_target.is_in_group("girlfriend"):
			reason = "npc_hit_by_streetlight"
		
		if reason != "":
			# Tìm player để gọi death camera nhìn về cột đèn
			var player = get_tree().get_first_node_in_group("player")
			if player and player.has_method("start_death_camera"):
				player.start_death_camera(global_position, func():
					emit_signal("game_over", reason)
				)
			else:
				emit_signal("game_over", reason)
		fall_target = null
