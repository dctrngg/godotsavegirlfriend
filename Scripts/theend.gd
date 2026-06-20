# theEnd
extends Area3D

signal game_over(reason: String)

func _ready():
	# Visible từ đầu, không cần ẩn
	visible = true

func _on_body_entered(body):
	if body.is_in_group("girlfriend"):
		emit_signal("game_over", "theend")
