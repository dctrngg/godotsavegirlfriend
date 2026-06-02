# falling_brick.gd
extends RigidBody3D

signal game_over(reason: String)

var triggered = false
var has_hit = false

func _ready():
	visible = true
	freeze = true

func _on_area_3d_body_entered(body):
	# Vùng trigger phía dưới — phát hiện người đi vào để thả gạch
	if triggered:
		return
	if body.is_in_group("player") or body.is_in_group("girlfriend"):
		triggered = true
		visible = true
		
		freeze = false

func _on_hit_area_body_entered(body):
	# Vùng va chạm của gạch — phát hiện gạch đập trúng ai
	if has_hit:
		return
	if not triggered:  # chỉ tính khi gạch đang rơi
		return
	if body.is_in_group("player"):
		has_hit = true
		emit_signal("game_over", "hit_by_brick")
	elif body.is_in_group("girlfriend"):
		has_hit = true
		emit_signal("game_over", "npc_hit_by_brick")
