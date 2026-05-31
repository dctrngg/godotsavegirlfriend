extends CanvasLayer

# Map lý do → thông báo hiển thị
const REASON_MESSAGES = {
	"npc_too_far": "Bạn đã bỏ rơi bạn gái!",
	"no_love": "Bạn quên nói I love you!",
	"hit_by_brick": "Bạn bị gạch rơi trúng!",
	"npc_hit_by_brick": "Bạn gái bị gạch rơi trúng!",
	"player_caught": "Bạn bị bắt gặp!",
	"time_up": "Hết giờ!",
}

@onready var reason_label = $Panel/Label # thêm Label vào scene nếu muốn

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func show_popup(reason: String = ""):
	if reason_label and REASON_MESSAGES.has(reason):
		reason_label.text = REASON_MESSAGES[reason]
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true

func _on_retry_button_pressed():
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().reload_current_scene()

func _on_menu_button_pressed():
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().reload_current_scene()


func _on_girlfriend_game_over(reason: String) -> void:
	pass # Replace with function body.
