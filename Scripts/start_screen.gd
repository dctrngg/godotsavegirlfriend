# start_screen.gd
extends CanvasLayer

func _ready():
	visible = true
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_start_button_pressed():
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	visible = false

func _on_settings_button_pressed():
	pass # thêm logic settings sau
