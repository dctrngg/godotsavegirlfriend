extends CanvasLayer

func _ready():
	visible = false
	# Cho phép UI hoạt động khi game pause
	process_mode = Node.PROCESS_MODE_ALWAYS

func show_popup():
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE  # hiện chuột
	get_tree().paused = true

func _on_retry_button_pressed():
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED  # ẩn chuột lại nếu game dùng FPS
	get_tree().reload_current_scene()

func _on_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
