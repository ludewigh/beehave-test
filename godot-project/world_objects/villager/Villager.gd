class_name Villager
extends CharacterBody2D

signal action_performed
signal animation_finished
signal target_reached

enum AnimationState {
	RUN = 0,
	IDLE = 1,
	CARRY = 2,
	CHOPPING = 3,
	WATERING = 4,
	DOING = 5,
	DIGGING = 6
}

var AnimationNames = {
	AnimationState.RUN:"Run",
	AnimationState.IDLE:"Idle",
	AnimationState.CARRY:"Carry",
	AnimationState.CHOPPING:"Chopping",
	AnimationState.WATERING:"Watering",
	AnimationState.DOING:"Doing",
	AnimationState.DIGGING:"Digging",
}

@export var villager_name: String
@export var villager_profession: String
@export var ACCELERATION: float = 540
@export var FRICTION: float = 770
@export var MAX_SPEED: float = 75
@export var target_position: Vector2: set = _set_target_location
@export var house_path: NodePath
@export var stash_area_path: NodePath
@export var ship_path: NodePath

@onready var animation_player = $AnimationPlayer
@onready var navigation_agent = $NavigationAgent2D 
@onready var voice_sounds = $VoiceSounds
@onready var grass_walk_sounds = $WalkOnGrassSounds
@onready var watering_sound = $WateringSound

var state = AnimationState.IDLE
var move_direction = Vector2.ZERO
var last_move_velocity = Vector2.ZERO
var current_animation = null
var house: House
var stash_area: StashArea
var ship: Ship

func _ready():
	randomize()
	house = get_node(house_path)
	stash_area = get_node(stash_area_path)
	ship = get_node(ship_path)
	target_position = global_position
	navigation_agent.set_target_position(target_position)
	velocity = Vector2.ZERO
	
func get_house() -> House:
	return house
	
func get_ship() -> Ship:
	return ship
	
func get_stash_area() -> StashArea:
	return stash_area
		
func water():
	state = AnimationState.WATERING
	voice_sounds.play()
	watering_sound.play()

func chop():
	state = AnimationState.CHOPPING
	voice_sounds.play()
	
func do():
	state = AnimationState.DOING
	voice_sounds.play()
	
func dig():
	state = AnimationState.DIGGING
	voice_sounds.play()
	
func carry():
	state = AnimationState.CARRY
	voice_sounds.play()
	
func is_carrying():
	return state == AnimationState.CARRY
	
func reset():
	state = AnimationState.RUN
	voice_sounds.play()
	
func idle():
	state = AnimationState.IDLE
	velocity = Vector2.ZERO
	
func move(direction:Vector2) -> void:
	move_direction = direction
	
func do_state(delta, animation):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	_play_animation(animation)
	set_velocity(velocity)
	move_and_slide()
	velocity = velocity
	
func move_state(delta, idle_animation, run_animation, max_speed, acceleration):
	if move_direction != Vector2.ZERO:
		last_move_velocity = move_direction
		look_at_direction(move_direction)
		_play_animation(run_animation)
		velocity = velocity.move_toward(move_direction * max_speed, acceleration * delta)
	else:
		_play_animation(idle_animation)
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	set_velocity(velocity)
	move_and_slide()
	velocity = velocity
	
func _physics_process(delta):
	if not visible:
		return
	var next_location = navigation_agent.get_next_path_position()
	var direction = (next_location - global_transform.origin).normalized()
	move(direction)
	
	match state:
		AnimationState.RUN, AnimationState.IDLE:
			move_state(delta, AnimationState.IDLE, AnimationState.RUN, MAX_SPEED, ACCELERATION)
		AnimationState.CARRY:
			move_state(delta, state, state, MAX_SPEED, ACCELERATION)
		_:
			do_state(delta, state)
		
func look_at_direction(direction:Vector2) -> void:
	direction = direction.normalized()
	move_direction = direction
	if current_animation != null:
		_play_animation(current_animation)
	
func _action_performed() -> void:
	emit_signal("action_performed")
	
func _set_target_location(tl):
	target_position = tl
	if navigation_agent != null:
		navigation_agent.set_target_position(target_position)

func _on_NavigationAgent2D_target_reached():
	emit_signal("target_reached")

func _play_walk_sound():
	if not visible:
		return
	grass_walk_sounds.play()
	
func _animation_finished():
	emit_signal("animation_finished")
	
func _play_animation(animation_type:int) -> void:
	var animation_type_string = AnimationNames[animation_type]
	var animation_name = animation_type_string + "_" + _get_direction_string(move_direction.angle())
	if animation_name != animation_player.current_animation:
		animation_player.stop(true)
	animation_player.play(animation_name)
	current_animation = animation_type
			
func _get_direction_string(angle:float) -> String:
	var angle_deg = round(rad_to_deg(angle))
	if angle_deg > -90.0 and angle_deg < 90.0:
		return "Right"
	return "Left"
