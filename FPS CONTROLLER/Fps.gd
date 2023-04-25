extends CharacterBody3D

# MOVEMENT SPEEDS.
var speed 
# NORMAL SPEED.
var normal_speed = 5.0
# SPRINT/RUNING SPEED.
var sprint_speed = 15.0
# accel_in_air STANDS FOR ACCELERATION IN HANPPENING IN AIR. 
# accel_normal STANDS FOR ACCELERATION IN NOT HANPPENING IN AIR BUT INSTEAD ON GROUND.
const accel_normal = 10.0
const accel_in_air = 1.0
#THESE CONSTANTS DEFINE TWO ACCELERATION VALUES:
#THESE VALUES CONTROL HOW QUICKLY THE PLAYER SPEEDS UP AND SLOWS DOWN IN DIFFERENT CONTEXTS.
# ACCEL_NORMAL FOR WHEN THE PLAYER IS ON THE GROUND, AND ACCEL_IN_AIR FOR WHEN THE PLAYER IS IN THE AIR. 
# ACCEL IS ABOUT THE CURRENT ACCELERATION.
@onready var accel = accel_normal
# Get the gravity from the project settings to be synced with RigidBody nodes.
#GETS THE GRAVITY AND JUMPING VARIABLES.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var jump_velocity #NO NEED TO SET JUMP VALUE BECAUSE THE CROUCH FUNCTIONS DOES IT'S VALUE Changing.
# LOWEST HEIGHT AND MAXIMUM.
var normal_height = 2.0
var crouch_height = 1.0
# LOWEST HEIGHT AND MAXIMUM TRANSITION SPEED OF CROUCHING.
var crouch_speed = 10.0

# MOUSE SENSITIVITY.
var mouse_sense = 0.1
#IMPROTANT VARIABLES FOR PLAYER MOVEMENT.
var is_forward_moving = false
var direction = Vector3()
var gravity_vector = Vector3()
var movement = Vector3()
# player.
@onready var head = $Head
@onready var camera3d = $Head/Camera3D
@onready var player_capsule = $CollisionShape3D
@onready var head_checker = $Head_checker

# CALLED WHEN THE NODE ENTERS THE SCENE TREE FOR THE FIRST TIME.
func _ready():
	#HIDES THE CURSOR.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#CHECKS THE MOUSE MOVEMENT INPUT.
func _input(event):
	#GET MOUSE INPUT FOR CAMERA ROTATION AND CLAMP THE UP AND DOWN ROTATIONS.
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

# CALLED EVERY FRAME. 'DELTA' IS THE ELAPSED TIME SINCE THE PREVIOUS FRAME.
# ALSO THIS WILL HANDLE ALL THE PLAYERS MOVEMENT AND PHYSICS.
func _physics_process(delta):
	# ADDS CROUCHING TO THE PLAYER MEANING IT CALLS THE CROUCH FUNCTION WHICH WE MADE.
	CROUCH(delta)
	# IF ESCAPE IS PRESSED IT WILL SHOW THE MOUSE CURSOR.
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#get keyboard input
	direction = Vector3.ZERO
	speed = normal_speed
	# GETS KEYBOARD INPUT.
	# GET THE INPUT DIRECTION AND HANDLE THE MOVEMENT/DECELERATION.
	# AS GOOD PRACTICE, YOU SHOULD REPLACE UI ACTIONS WITH CUSTOM GAMEPLAY ACTIONS.
	var h_rotation = global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("MOVE_BACKWARD") - Input.get_action_strength("MOVE_FORWARD")
	if f_input < 0.0:
		is_forward_moving = true
	else:
		is_forward_moving = false
	var h_input = Input.get_action_strength("MOVE_RIGHT") - Input.get_action_strength("MOVE_LEFT")
	direction = Vector3(h_input, 0.0, f_input).rotated(Vector3.UP, h_rotation).normalized()
	#SWITCHING BETWEEN SPEEDS 
	if Input.is_action_pressed("sprint") and is_forward_moving:
		speed = sprint_speed
	if Input.is_action_pressed("crouch") and Input.is_action_pressed("sprint"):
		speed = normal_speed
	#jumping and gravity.
	# Adds the gravity.
	if not is_on_floor():
		accel = accel_in_air
		velocity.y -= gravity * delta
	else:
		accel = accel_normal
		velocity.y -= jump_velocity 
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		accel = accel_in_air
		velocity.y = jump_velocity 
	#make it move
	velocity = velocity.lerp(direction * speed, accel * delta)
	movement = velocity + gravity_vector
	#Moves the body based on velocity.
	move_and_slide()
	# the crouch function.
func CROUCH(delta):
	var colliding = false
	if head_checker.is_colliding():
		colliding = true
	if Input.is_action_pressed("crouch"):
		# IT WILL LOWER THE SIZE OF THE CAPSULE BY THE CROUCHING SPEED AND DECREASES THE JUMP VALUE AND ,
		# SETS SPEED TO NORMAL SPEED. 
		speed = normal_speed
		jump_velocity = 0.0
		player_capsule.shape.height -= crouch_speed * delta
	elif not colliding:
		# IT WILL INCREASE THE SIZE OF THE CAPSULE BY THE CROUCHING SPEED AND RESETS THE JUMP VALUE.
		jump_velocity = 3.5
		player_capsule.shape.height += crouch_speed * delta
	player_capsule.shape.height =  clamp(player_capsule.shape.height, crouch_height,normal_height)
