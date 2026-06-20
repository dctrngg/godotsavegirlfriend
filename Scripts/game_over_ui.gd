extends CanvasLayer

const REASON_MESSAGES = {
	"npc_too_far": [
		"Anh định bỏ rơi em thật à? Đồ tồi!",
		"Chân em ngắn anh phải đợi chứ, đồ vô tâm!",
		"Hóa ra em chỉ là người thừa trong cuộc đời anh thôi đúng không?",
		"Anh đi luôn đi, đừng bao giờ quay lại nhìn em nữa!"
	],
	"no_love": [
		"Hôm nay anh chưa nói yêu em đâu đấy, anh hết yêu em rồi à?",
		"Thì ra bấy lâu nay anh chỉ lừa dối em thôi...",
		"Sự im lặng của anh làm em thấy sợ đấy, đồ đáng ghét!",
		"Vô tâm nó vừa vừa thôi chứ, một câu yêu em khó thế sao?"
	],
	"hit_by_brick": [
		"Đã bảo nhìn lên trên rồi mà, anh ngốc quá đi!",
		"Anh định dùng đầu để thử độ cứng của gạch à?",
		"Hậu đậu thế này thì làm sao mà bảo vệ được em cơ chứ!",
		"Gạch rơi trúng đầu rồi, có làm sao không đồ ngốc này?"
	],
	"npc_hit_by_brick": [
		"Anh đứng nhìn em bị gạch đập thế à? Đồ mưu sát!",
		"Đau chết em rồi! Anh không biết che cho em à?",
		"Anh muốn em biến mất để anh đi với cô khác đúng không?",
		"Chia tay đi! Anh định ám sát bạn gái mình đấy à?"
	],
	"player_caught": [
		"Làm chuyện xấu bị bắt quả tang rồi nhé, đáng đời!",
		"Anh định giấu em cái gì đúng không? Khai mau!",
		"Đồ tồi! Anh tưởng anh trốn được chắc?"
	],
	"time_up": [
		"Hết giờ rồi, anh định để em chờ đến bao giờ nữa?",
		"Anh chậm chạp như sên ấy, em đi về đây!",
		"Em không có cả đời để đợi anh đâu nhé!"
	],
	"hit_by_car": [
		"Mắt anh để trên đầu à? Xe to thế kia mà không thấy!",
		"Anh định đi sang thế giới bên kia mà không có em à?",
		"Lần sau nhìn đường giùm em cái, đồ hậu đậu!"
	],
	"npc_hit_by_car": [
		"Anh dắt tay em kiểu gì mà để em bị xe đâm thế hả?",
		"Anh muốn hưởng tiền bảo hiểm của em đúng không?",
		"Không tin được là anh lại để em gặp nguy hiểm như thế!"
	],
	"stepped_in_puddle": [
		"Mình đê ý tí xíu được hông anh",
		"Anh làm vậy mà coi được á hả!",
		"RỒi nhắm đi được thì đi luôn đi nha "
	],
	"npc_stepped_in_puddle": [
		"Bẩn hết đồ em rồi! Anh đền đi, đồ đáng ghét!",
		"Anh không biết nhắc e à? Đồ vô tâm!",
		"Em không đi nữa! Nhìn bộ dạng em bây giờ xem, tại anh hết!"
	],
	"npc_stepped_in_trash": [
		"Anh dắt em đi kiểu gì mà vào thẳng bãi rác thế hả?!",
		"Trong mắt anh em chỉ xứng đáng đứng cạnh thùng rác thôi sao?",
		"Kỷ niệm ngày yêu nhau anh dắt em đi ngắm bãi rác à? Đồ tồi!"
	],
	"stepped_in_trash": [
		"Đầu óc anh để đi đâu mà lại lao đầu vào thùng rác thế?",
		"Anh định hóa thân thành gấu rác à? Nhìn bẩn chết đi được!",
		"Chừa cái tội vừa đi vừa nhìn cô khác nhé, lao vào đống rác rồi kìa!"
	],
	"caught_staring": [
		"Nhìn người ta chằm chằm thế, chưa ai dạy phép lịch sự à?",
		"Mắt anh dính vào người ta rồi, em không ghen đâu đấy nhé!",
		"Anh nhìn người ta lâu thế, thích hơn em à?"
	],
	"hit_by_tree": [
		"Cây đổ trúng đầu rồi, anh đi rừng mà không nhìn đường à?",
		"Anh định làm người rừng Tarzan đấy à?",
	],
	"npc_hit_by_tree": [
		"Anh để cây đổ trúng em thế à, đồ vô tâm!",
		"Anh muốn em biến mất dưới gốc cây đúng không?",
	],
	"hit_by_streetlight": [
		"Cột đèn đổ trúng đầu rồi, đau không đồ ngốc!",
		"Anh định thách đấu với cột đèn à? Thua rồi nhé!",
	],
	"npc_hit_by_streetlight": [
		"Anh để cột đèn đổ trúng em thế à? Đồ tệ!",
		"Bảo vệ bạn gái kiểu gì vậy trời!",
	],
	"theend":
		[
			"Sao anh hong chở em về mà bắt em đi bộ z"
		]
}

@onready var reason_label = $Panel/Label

# ========= SOUND EFFECTS =========
# Kéo file âm thanh (.wav/.ogg) tương ứng vào từng ô ở tab Inspector 
# trong Godot.

@export_group("SFX theo nguyên nhân thua")
@export var sfx_npc_too_far: AudioStream
@export var sfx_no_love: AudioStream
@export var sfx_hit_by_brick: AudioStream
@export var sfx_npc_hit_by_brick: AudioStream
@export var sfx_player_caught: AudioStream
@export var sfx_time_up: AudioStream
@export var sfx_hit_by_car: AudioStream
@export var sfx_npc_hit_by_car: AudioStream
@export var sfx_stepped_in_puddle: AudioStream
@export var sfx_npc_stepped_in_puddle: AudioStream
@export var sfx_npc_stepped_in_trash: AudioStream
@export var sfx_stepped_in_trash: AudioStream
@export var sfx_caught_staring: AudioStream
@export var sfx_hit_by_tree: AudioStream
@export var sfx_npc_hit_by_tree: AudioStream
@export var sfx_hit_by_streetlight: AudioStream
@export var sfx_npc_hit_by_streetlight: AudioStream
@export var sfx_theend: AudioStream


# Dictionary map reason -> AudioStream, được build trong _ready() từ các ô export ở trên
var _reason_sounds: Dictionary = {}

# Player phát âm thanh, tạo bằng code nên không cần thêm node thủ công trong scene
var _reason_sound_player: AudioStreamPlayer

func _ready():
	visible = false
	# PROCESS_MODE_ALWAYS để UI vẫn hiện được dù game paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	_reason_sound_player = AudioStreamPlayer.new()
	add_child(_reason_sound_player)
	# Để player vẫn phát được âm thanh dù game đang paused
	_reason_sound_player.process_mode = Node.PROCESS_MODE_ALWAYS

	_reason_sounds = {
		"npc_too_far": sfx_npc_too_far,
		"no_love": sfx_no_love,
		"hit_by_brick": sfx_hit_by_brick,
		"npc_hit_by_brick": sfx_npc_hit_by_brick,
		"player_caught": sfx_player_caught,
		"time_up": sfx_time_up,
		"hit_by_car": sfx_hit_by_car,
		"npc_hit_by_car": sfx_npc_hit_by_car,
		"stepped_in_puddle": sfx_stepped_in_puddle,
		"npc_stepped_in_puddle": sfx_npc_stepped_in_puddle,
		"npc_stepped_in_trash": sfx_npc_stepped_in_trash,
		"stepped_in_trash": sfx_stepped_in_trash,
		"caught_staring": sfx_caught_staring,
		"hit_by_tree": sfx_hit_by_tree,
		"npc_hit_by_tree": sfx_npc_hit_by_tree,
		"hit_by_streetlight": sfx_hit_by_streetlight,
		"npc_hit_by_streetlight": sfx_npc_hit_by_streetlight,
		"theend": sfx_theend
	}

# Hàm kích hoạt âm thanh độc lập ngay khi vừa chạm, được gọi từ world.gd
func play_sfx_only(reason: String) -> void:
	_play_reason_sound(reason)

func show_popup(reason: String = ""):
	# Đã loại bỏ hoàn toàn việc gọi âm thanh ở đây để không bị trùng lặp tiếng
	if reason_label and REASON_MESSAGES.has(reason):
		# Sử dụng pick_random() để lấy ngẫu nhiên 1 câu trong danh sách mảng dữ liệu
		var messages = REASON_MESSAGES[reason]
		reason_label.text = messages.pick_random()

	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true

# Phát SFX theo nguyên nhân thua
func _play_reason_sound(reason: String) -> void:
	var sound: AudioStream = _reason_sounds.get(reason)
	if sound:
		# Đảm bảo Node phát âm thanh luôn hoạt động bất chấp trạng thái pause của game
		if _reason_sound_player.process_mode != Node.PROCESS_MODE_ALWAYS:
			_reason_sound_player.process_mode = Node.PROCESS_MODE_ALWAYS
			
		_reason_sound_player.stream = sound
		_reason_sound_player.play()

func _on_retry_button_pressed():
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().reload_current_scene()

func _on_menu_button_pressed():
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().reload_current_scene()

func _on_girlfriend_game_over(reason: String) -> void:
	pass
