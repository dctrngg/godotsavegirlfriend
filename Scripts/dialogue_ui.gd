extends CanvasLayer

# Danh sách lời thoại theo từng tình huống (key)
# Gọi show_dialogue("key") từ npc.gd để hiển thị
const DIALOGUES = {
	"greet": [
		"Anh ơi, hôm nay đi đâu thế?",
		"Anh đến rồi à, em chờ lâu lắm đó!",
		"Ồ, cuối cùng anh cũng nhớ đến em rồi!"
	],
	"love": [
		"Anh có yêu em không? Nói đi!",
		"Em thích ở cạnh anh lắm đó, anh có biết không?",
		"Hôm nay anh đẹp trai hơn hôm qua đó, nhưng em không khen đâu nhé!",
		"Anh nắm tay em đi, em sợ lạc!"
	],
	"warning": [
		"Anh cẩn thận nhé, em lo lắm đó!",
		"Đừng có liều mạng nữa, tim em không chịu nổi đâu!",
		"Lần này mà anh làm em sợ nữa là em giận thật đó!"
	],
	"idle_chat": [
		"Anh có nghe em nói không vậy?",
		"Đứng gần em một chút được không? Em lạnh...",
		"Anh đang nghĩ gì vậy? Nói cho em nghe với!"
	],
	"jealous": [
		"Anh nhìn ai đó thế, cẩn thận không em ghen đó!",
		"Anh toàn để ý người khác, em buồn lắm đó!",
		"Sao anh không nhìn em một cái đi?"
	],
}

# Tốc độ hiện chữ (giây/ký tự)
const CHAR_SPEED = 0.03
# Thời gian hiện full box sau khi hết chữ (giây)
const DISPLAY_DURATION = 2.5

@onready var panel = $Panel
@onready var dialogue_label = $Panel/DialogueLabel
@onready var speaker_label = $Panel/SpeakerLabel
@onready var next_indicator = $Panel/NextIndicator

var _queue: Array = []
var _current_line := ""
var _char_index := 0
var _typing := false
var _wait_timer := 0.0
var _waiting := false

func _ready():
	visible = false
	if next_indicator:
		next_indicator.visible = false

func _process(delta):
	if not visible:
		return

	if _typing:
		_wait_timer += delta
		if _wait_timer >= CHAR_SPEED:
			_wait_timer = 0.0
			_char_index += 1
			dialogue_label.text = _current_line.substr(0, _char_index)
			if _char_index >= _current_line.length():
				_typing = false
				_waiting = true
				_wait_timer = 0.0
				if next_indicator:
					next_indicator.visible = true
		return

	if _waiting:
		_wait_timer += delta
		if _wait_timer >= DISPLAY_DURATION:
			_waiting = false
			if next_indicator:
				next_indicator.visible = false
			_show_next_line()

# Gọi từ NPC: show_dialogue("love") hoặc truyền array tuỳ ý
func show_dialogue(key_or_lines):
	_queue.clear()
	_typing = false
	_waiting = false

	if key_or_lines is String:
		if DIALOGUES.has(key_or_lines):
			_queue = DIALOGUES[key_or_lines].duplicate()
		else:
			push_warning("DialogueUI: key '%s' không tồn tại." % key_or_lines)
			return
	elif key_or_lines is Array:
		_queue = key_or_lines.duplicate()

	if _queue.is_empty():
		return

	if speaker_label:
		speaker_label.text = "Bạn gái"

	visible = true
	_show_next_line()

func _show_next_line():
	if _queue.is_empty():
		_close()
		return

	_current_line = _queue.pop_front()
	_char_index = 0
	dialogue_label.text = ""
	_typing = true
	_wait_timer = 0.0

func _close():
	visible = false
	_queue.clear()
	_typing = false
	_waiting = false

# Cho phép player nhấn interact để skip/next nhanh hơn
func _input(event):
	if not visible:
		return
	if not event is InputEventKey:
		return
	if not event.pressed:
		return
	if Input.is_action_just_pressed("interact"):
		if _typing:
			_typing = false
			dialogue_label.text = _current_line
			_waiting = true
			_wait_timer = 0.0
			if next_indicator:
				next_indicator.visible = true
		elif _waiting:
			_waiting = false
			if next_indicator:
				next_indicator.visible = false
			_show_next_line()
		get_viewport().set_input_as_handled()
