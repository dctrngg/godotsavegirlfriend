extends PathFollow3D

@export var max_speed: float = 7.0       # tốc độ tối đa, chỉnh khác nhau cho từng xe
@export var start_offset: float = -1.0   # -1 = random, 0.0 đến 1.0 = tự set
@export var min_gap: float = 0.06        # khoảng cách tối thiểu với xe phía trước
@export var acceleration: float = 3.0   # tốc độ tăng tốc
@export var brake_force: float = 8.0    # tốc độ phanh

signal game_over(reason: String)

var current_speed: float = 0.0
var waiting: bool = false

func _ready():
	if start_offset < 0:
		progress_ratio = randf()
	else:
		progress_ratio = start_offset
	current_speed = max_speed

func _process(delta):
	if waiting:
		return

	var car_ahead = _get_car_ahead()

	if car_ahead:
		var gap = _get_gap(car_ahead)
		if gap < min_gap * 0.5:
			current_speed = move_toward(current_speed, 0.0, brake_force * delta)
		elif gap < min_gap:
			var target_speed = max_speed * (gap / min_gap)
			current_speed = move_toward(current_speed, target_speed, brake_force * delta)
		else:
			current_speed = move_toward(current_speed, max_speed, acceleration * delta)
	else:
		current_speed = move_toward(current_speed, max_speed, acceleration * delta)

	var prev_ratio = progress_ratio
	progress += current_speed * delta

	# Phát hiện xe vừa qua vạch xuất phát (ratio reset về gần 0)
	if prev_ratio > 0.9 and progress_ratio < 0.1:
		_wait_random()

func _get_car_ahead() -> PathFollow3D:
	var siblings = get_parent().get_children()
	var closest: PathFollow3D = null
	var closest_gap = INF

	for car in siblings:
		if car == self or not car is PathFollow3D:
			continue
		var gap = _get_gap(car)
		# Chỉ tính xe phía trước (gap dương)
		if gap > 0 and gap < closest_gap:
			closest_gap = gap
			closest = car

	return closest

func _get_gap(other: PathFollow3D) -> float:
	var diff = other.progress_ratio - progress_ratio
	# Xử lý vòng lặp (xe phía trước đã qua vạch xuất phát)
	if diff < 0:
		diff += 1.0
	return diff

func _wait_random():
	waiting = true
	current_speed = 0.0
	var wait_time = randf_range(5.0, 10.0)
	await get_tree().create_timer(wait_time).timeout
	waiting = false

func _on_area_3d_body_entered(body):
	if waiting or current_speed <= 0:
		return
	if body.is_in_group("player"):
		emit_signal("game_over", "hit_by_car")
	elif body.is_in_group("girlfriend"):
		emit_signal("game_over", "npc_hit_by_car")
