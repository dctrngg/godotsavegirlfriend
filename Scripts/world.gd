extends Node

@onready var player = $Player
@onready var game_over_ui = $GameOverUI
@onready var girlfriend = $girlfriend

const GIRLFRIEND_REASONS = [
	"npc_too_far",
	"no_love",
	"npc_hit_by_brick",
	"npc_hit_by_car",
	"npc_stepped_in_puddle",
]

const SOURCE_REASONS = [
	"hit_by_brick",
	"hit_by_car",
	"stepped_in_puddle",
	"caught_staring",  # ← thêm vào đây
]

func _ready():
	girlfriend.game_over.connect(_on_game_over.bind(girlfriend))
	
	for brick in get_tree().get_nodes_in_group("falling_brick"):
		if not brick.game_over.is_connected(_on_game_over):
			brick.game_over.connect(_on_game_over.bind(brick))
	
	for car in get_tree().get_nodes_in_group("car"):
		if not car.game_over.is_connected(_on_game_over):
			car.game_over.connect(_on_game_over.bind(car))
	
	for puddle in get_tree().get_nodes_in_group("puddle"):
		if not puddle.game_over.is_connected(_on_game_over):
			puddle.game_over.connect(_on_game_over.bind(puddle))

	# ← thêm đoạn này
	for pedestrian in get_tree().get_nodes_in_group("pedestrian"):
		if not pedestrian.game_over.is_connected(_on_game_over):
			pedestrian.game_over.connect(_on_game_over.bind(pedestrian))

func _physics_process(delta):
	get_tree().call_group("girlfriend", "update_target_location", player.global_transform.origin)

func _on_game_over(reason: String, source_node: Node):
	var look_target: Node3D

	if reason in GIRLFRIEND_REASONS:
		look_target = girlfriend
	elif reason in SOURCE_REASONS:
		if source_node is Node3D:
			look_target = source_node as Node3D
		else:
			game_over_ui.show_popup(reason)
			return
	else:
		game_over_ui.show_popup(reason)
		return

	player.start_death_camera(look_target.global_transform.origin, func():
		game_over_ui.show_popup(reason)
	)
