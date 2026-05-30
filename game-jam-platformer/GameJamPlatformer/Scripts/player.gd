extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var die_sound: AudioStreamPlayer2D = $DieSound
@onready var dash_sound: AudioStreamPlayer2D = $DashSound
@onready var drop_sound: AudioStreamPlayer2D = $DropSound
# Walk Vars
@export var walk_speed : float = 150.0
@export_range(0,1) var acceleration : float = 0.1
@export_range(0,1) var deceleration : float = 0.05
@export var run_speed : float = 350.0
# Jump Vars
@export var jump_force : float = -800.0
@export_range(0,1) var decelerate_on_jump_release : float = 0.5

@export_range(1,2) var fast_drop : float = 2

@export var dash_speed : float = 1000.0
@export var dash_max_distance : float = 300.0
@export var dash_curve : Curve
@export var dash_cooldown : float = 1.0

var alive : bool = true
var can_move : bool = true


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_dashing : bool = false
var dash_start_position : float = 0
var dash_direction : float = 0
var dash_timer : float = 0

func _physics_process(delta: float) -> void:
	
	if !alive:
		return
	
	
	# Add animation
	if abs(velocity.x) > 1:
		animated_sprite_2d.animation = "run"
	else:
		animated_sprite_2d.animation = "idle"
	# Wall animation
	if not is_on_floor() and is_on_wall():
		animated_sprite_2d.animation = "walljump"
	
	# Flip direction
	if velocity.x < 0:
		animated_sprite_2d.flip_h = true
	elif velocity.x >0:
		animated_sprite_2d.flip_h = false
	
	# Add the gravity.
	if not is_on_floor():
		if is_on_wall() and not Input.is_action_pressed("drop"):
			animated_sprite_2d.animation = "walljump"
			velocity = get_gravity() * delta * 0
			velocity += get_gravity() * delta
		else:
			animated_sprite_2d.animation = "jump"
			velocity += get_gravity() * delta
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var speed
	if Input.is_action_pressed("run"):
		speed = run_speed
	else:
		speed = walk_speed
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x , direction * speed * 2, speed * acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed * deceleration/1.2)
		
	
	if can_move:
		# Handle jump.
		if Input.is_action_just_pressed("jump") and (is_on_floor() or is_on_wall()):
			jump_sound.play()
			velocity.y = jump_force * remap(abs(velocity.x), 0, run_speed, 1.5, 0.9)
			
		if Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y *= decelerate_on_jump_release
		
		if Input.is_action_just_pressed("drop") and velocity.y > 0 and not is_on_wall():
			drop_sound.play()
			velocity.y *= fast_drop

	
		# Dashing
		if Input.is_action_just_pressed("dash") and direction and not is_dashing and dash_timer <= 0:
			is_dashing = true
			dash_sound.play()
			dash_start_position = position.x
			dash_direction = direction
			dash_timer = dash_cooldown
		# dash action
		if is_dashing:
			var current_distance = abs(position.x - dash_start_position)
			if current_distance >= dash_max_distance or is_on_wall():
				is_dashing = false
			else:
				velocity.x = dash_direction * dash_speed * dash_curve.sample(current_distance / dash_max_distance)
				velocity.y = 0
			
		# dash timer
		if dash_timer > 0:
			dash_timer -= delta
		
			

	move_and_slide()

func die () -> void:
	die_sound.play()
	animated_sprite_2d.animation = "hit"
	alive = false
