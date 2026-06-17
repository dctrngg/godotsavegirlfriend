extends CharacterBody3D

signal game_over(reason: String)

@onready var nav_agent = $NavigationAgent3D

@export var walk_anim = "walking"
@export var STARE_LIMIT = 2.0
@export var SPEED = 1.5
@export var IDLE_TIME = 2.0
@export var active_distance = 80.0
@export var update_interval = 0.1

var anim_player: AnimationPlayer
var is_being_watched = false
var watch_timer = 0.0
var waypoints: Array = []
var current_waypoint = 0
var is_idling = false
var idle_timer = 0.0
var update_timer = 0.0
var player: Node3D
var is_active = true

func _ready():
	player = get_tree().get_first_node_in_group("player")
	anim_player = _find_animation_player(self)
	if anim_player and anim_player.has_animation(walk_anim):
		anim_player.play(walk_anim)
		anim_player.get_animation(walk_anim).loop_mode = Animation.LOOP_LINEAR
	call_deferred("_generate_waypoints")

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var result = _find_animation_player(child)
		if result:
			return result
	return null

func _generate_waypoints():
	var center = global_position
	for i in range(4):
		var angle = i * PI / 2
		waypoints.append(Vector3(
			center.x + cos(angle) * 3.0,
			center.y,
			center.z + sin(angle) * 3.0
		))
	_set_next_waypoint()

func _set_next_waypoint():
	if not waypoints.is_empty():
		nav_agent.set_target_position(waypoints[current_waypoint])

func _physics_process(delta):
	if player:
		var dist_sq = global_position.distance_squared_to(player.global_position)
		if dist_sq > active_distance * active_distance:
			if is_active:
				is_active = false
				velocity = Vector3.ZERO
				if anim_player:
					anim_player.stop()
			move_and_slide()
			return
		else:
			if not is_active:
				is_active = true
				if anim_player and anim_player.has_animation(walk_anim):
					anim_player.play(walk_anim)

	update_timer += delta
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0

	_check_stare(delta)

	if update_timer >= update_interval:
		update_timer = 0.0
		_ai_move()

	move_and_slide()

func _ai_move():
	if waypoints.is_empty():
		return

	if is_idling:
		velocity.x = 0
		velocity.z = 0
		idle_timer += update_interval
		if idle_timer >= IDLE_TIME:
			is_idling = false
			idle_timer = 0.0
			current_waypoint = (current_waypoint + 1) % waypoints.size()
			_set_next_waypoint()
			if anim_player:
				anim_player.play(walk_anim)
		return

	if nav_agent.is_navigation_finished():
		is_idling = true
		idle_timer = 0.0
		velocity.x = 0
		velocity.z = 0
		if anim_player:
			anim_player.stop(false)
		return

	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

	if direction.length() > 0.1:
		rotation.y = atan2(-direction.x, -direction.z)

func _check_stare(delta):
	if is_being_watched:
		watch_timer += delta
		if watch_timer >= STARE_LIMIT:
			emit_signal("game_over", "caught_staring")
	else:
		watch_timer = 0.0

func start_watching():
	is_being_watched = true

func stop_watching():
	is_being_watched = false
	watch_timer = 0.0
