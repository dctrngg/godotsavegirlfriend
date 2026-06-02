extends RigidBody3D

signal game_over(reason: String)

var triggered = false
var has_hit = false

func _ready():
	visible = true
	freeze = true
	
	# Bật tính năng nhận diện va chạm của RigidBody3D
	contact_monitor = true
	max_contacts_reported = 5
	
	# Bật Continuous Collision Detection để chống lỗi xuyên thấu (Tunneling)
	continuous_cd = true 
	
	# Nối tín hiệu va chạm của chính viên gạch
	body_entered.connect(_on_brick_body_entered)

func _on_area_3d_body_entered(body):
	# Trigger zone — thả gạch khi player/girlfriend đi vào
	if triggered:
		return
	if body.is_in_group("player") or body.is_in_group("girlfriend"):
		triggered = true
		freeze = false

func _on_brick_body_entered(body):
	# Detect gạch đập trúng ai trực tiếp qua RigidBody3D
	if has_hit:
		return
	if not triggered:
		return
		
	if body.is_in_group("player"):
		has_hit = true
		emit_signal("game_over", "hit_by_brick")
	elif body.is_in_group("girlfriend"):
		has_hit = true
		emit_signal("game_over", "npc_hit_by_brick")
