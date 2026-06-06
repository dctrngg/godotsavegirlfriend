# npc.gd
extends CharacterBody3D

signal game_over(reason: String)

@onready var nav_agent = $NavigationAgent3D
@onready var interact_label = $InteractLabel

var SPEED = 3.0
var FOLLOW_DISTANCE = 3.0
var RESUME_DISTANCE = 4.5
var MAX_DISTANCE = 8.0
var TIME_LIMIT = 3.0
var time_too_far = 0.0

var LOVE_TIMER_LIMIT = 30.0
var love_timer = 0.0
var INTERACT_DISTANCE = 2.5

var player: Node3D

func _ready():
	player = get_tree().get_first_node_in_group("player")
	if interact_label:
		interact_label.visible = false

func _physics_process(delta):
	_check_distance(delta)
	_follow_player()
	_check_love_timer(delta)
	_check_interact()
	_update_interact_label()

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
			_game_over("npc_too_far")
	else:
		time_too_far = 0.0

func _check_love_timer(delta):
	love_timer += delta
	if love_timer >= LOVE_TIMER_LIMIT:
		_game_over("no_love")

func _check_interact():
	if not player:
		return
	if not Input.is_action_just_pressed("interact"):
		return
	var dist = global_transform.origin.distance_to(player.global_transform.origin)
	if dist <= INTERACT_DISTANCE:
		love_timer = 0.0
		print("I love you!")

func _update_interact_label():
	if not player or not interact_label:
		return
	var dist = global_transform.origin.distance_to(player.global_transform.origin)
	interact_label.visible = dist <= INTERACT_DISTANCE

func _game_over(reason: String):
	emit_signal("game_over", reason)
