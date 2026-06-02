extends Node

@onready var player = $Player
@onready var game_over_ui = $GameOverUI

func _ready():
	# Connect girlfriend
	if not $girlfriend.game_over.is_connected(game_over_ui.show_popup):
		$girlfriend.game_over.connect(game_over_ui.show_popup)
	
	# Connect FallingBrick
	if not $FallingNode/FallingBrick.game_over.is_connected(game_over_ui.show_popup):
		$FallingNode/FallingBrick.game_over.connect(game_over_ui.show_popup)
	
	# Connect tất cả xe trong group "car"
	for car in get_tree().get_nodes_in_group("car"):
		if not car.game_over.is_connected(game_over_ui.show_popup):
			car.game_over.connect(game_over_ui.show_popup)
	
	# Connect tất cả puddle trong group "puddle"
	for puddle in get_tree().get_nodes_in_group("puddle"):
		if not puddle.game_over.is_connected(game_over_ui.show_popup):
			puddle.game_over.connect(game_over_ui.show_popup)

func _physics_process(delta):
	get_tree().call_group("girlfriend", "update_target_location", player.global_transform.origin)
