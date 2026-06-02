# puddle.gd
extends Area3D

signal game_over(reason: String)

func _ready():
	# Visible từ đầu, không cần ẩn
	visible = true

func _on_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("game_over", "stepped_in_puddle")
	elif body.is_in_group("npc"):
		emit_signal("game_over", "npc_stepped_in_puddle")
