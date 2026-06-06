# falling_tree.gd
extends StaticBody3D

signal game_over(reason: String)

@onready var anim_player = $AnimationPlayer
@onready var area = $Area3D

var triggered = false
var has_hit = false
var fall_direction = Vector3.ZERO

func _ready():
	pass

func _on_area_3d_body_entered(body):
	if triggered:
		return
	if body.is_in_group("player") or body.is_in_group("girlfriend"):
		triggered = true
		# Tính hướng đổ về phía player
		fall_direction = (body.global_position - global_position).normalized()
		fall_direction.y = 0
		_fall()

func _fall():
	# Xoay HitArea về hướng player trước khi cây đổ
	var hit_area = $HitArea
	hit_area.look_at(global_position + fall_direction, Vector3.UP)
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Tính góc đổ theo hướng player
	var angle_x = deg_to_rad(90) * fall_direction.z
	var angle_z = deg_to_rad(-90) * fall_direction.x
	
	# Giai đoạn 1: Ngả chậm
	tween.tween_property(self, "rotation", Vector3(
		angle_x * 0.33, rotation.y, angle_z * 0.33
	), 0.8)
	
	# Giai đoạn 2: Đổ nhanh
	tween.tween_property(self, "rotation", Vector3(
		angle_x, rotation.y, angle_z
	), 0.7)
	
	# Giai đoạn 3: Nảy nhẹ
	tween.tween_property(self, "rotation", Vector3(
		angle_x * 0.95, rotation.y, angle_z * 0.95
	), 0.2)
	
	tween.tween_callback(_check_hit_on_land)

func _check_hit_on_land():
	if has_hit:
		return
	# Kiểm tra ai bị cây đè
	var bodies = $HitArea.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			has_hit = true
			emit_signal("game_over", "hit_by_tree")
			return
		elif body.is_in_group("girlfriend"):
			has_hit = true
			emit_signal("game_over", "npc_hit_by_tree")
			return
