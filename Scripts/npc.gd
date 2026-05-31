# npc.gd
extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
@onready var game_over_ui = $"../GameOverUI"

var SPEED = 3.0
var FOLLOW_DISTANCE = 3.0
var RESUME_DISTANCE = 4.5
var MAX_DISTANCE = 8.0
var TIME_LIMIT = 3.0
var time_too_far = 0.0
var player: Node3D

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	_check_distance(delta)
	_follow_player()

func _follow_player():
	if not player:
		return

	var dist_to_player = global_transform.origin.distance_to(player.global_transform.origin)

	if dist_to_player <= FOLLOW_DISTANCE:
		velocity = Vector3.ZERO
		return

	if dist_to_player > RESUME_DISTANCE:
		nav_agent.set_target_position(player.global_transform.origin)

	if nav_agent.is_navigation_finished():
		velocity = Vector3.ZERO
		return

	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_transform.origin).normalized()
	velocity = direction * SPEED
	move_and_slide()

func _check_distance(delta):
	if not player:
		return

	var dist = global_transform.origin.distance_to(player.global_transform.origin)

	if dist > MAX_DISTANCE:
		time_too_far += delta
		if time_too_far >= TIME_LIMIT:
			_game_over()
	else:
		time_too_far = 0.0

func _game_over():
	if game_over_ui:
		game_over_ui.show_popup()
