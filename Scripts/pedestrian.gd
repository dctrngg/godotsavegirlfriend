# pedestrian.gd
extends CharacterBody3D

signal game_over(reason: String)

var is_being_watched = false
var watch_timer = 0.0
var STARE_LIMIT = 2.0
func _process(delta):
	if is_being_watched:
		watch_timer += delta
		print("Đang nhìn: ", watch_timer)  # ← thêm dòng này
		if watch_timer >= STARE_LIMIT:
			emit_signal("game_over", "caught_staring")
	else:
		watch_timer = 0.0

func start_watching():
	is_being_watched = true
	print("Bắt đầu nhìn!")  # ← thêm dòng này

func stop_watching():
	is_being_watched = false
	watch_timer = 0.0
	print("Nhìn đi chỗ khác")  # ← thêm dòng này
