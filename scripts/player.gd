extends CharacterBody3D

signal coin_collected

@export_subgroup("Components")
@export var view:Node3D = null
@export_subgroup("Properties")
@export var movement_speed = 250
@export var jump_strength = 500
@export var double_jump_strength = 350

@export_subgroup("Inputs")
@export var move_left:String = "p1_left"
@export var move_right:String = "p1_right"
@export var move_forward:String = "p1_forward"
@export var move_backward:String = "p1_backward"
@export var jump:String = "p1_jump"

var movement_velocity: Vector3
var rotation_direction: float
var gravity
var defalut_gravity = 23
var double_jump_gravity = 17
#shoot
@export_subgroup("Oters")
@export var bullet_scene : PackedScene  
var pivot_l : Marker3D   
var pivot_r : Marker3D 
var camera: Camera3D
var direction1 : Vector3
var direction2 : Vector3
var bullet1: RigidBody3D
var bullet2: RigidBody3D
@export var bullet_speed: float = 50

#INPUT
var input:Vector3 = Vector3.ZERO
var input_keyboard:Vector2 = Vector2.ZERO

var jump_single: bool = false
var jump_double: bool = false
var is_shooting = false
var coins = 0

@onready var particles_trail = $ParticlesTrail
@onready var sound_footsteps = $SoundFootsteps
@onready var model:Node3D = $Character
#@onready var animation:AnimationPlayer = $Character/AnimationPlayer
@onready var animation_tree:AnimationTree = $AnimationTree
#@onready var gunz_a_l:MeshInstance3D  = $Character/Armature/Skeleton3D/GunzA_L
#@onready var gunz_a_r:MeshInstance3D = $Character/Armature/Skeleton3D/GunzA_R
#@onready var standing_shape:CollisionShape3D = $StandingShape
#@onready var flipped_shape:CollisionShape3D = $FlippedShape
#@onready var character: Node3D = $Character
#@onready var standing_shape_leg: CollisionShape3D = $StandingShapeLeg
#@onready var flipped_shape_leg: CollisionShape3D = $FlippedShapeLeg
#

#variable velocity 
var applied_velocity: Vector3

#state machine

#anim player
var animation_states = {
	"Idle": "Idle",
	"Jump": "Jump",
	"Fall": "Fall",
	"DoubleJump": "DoubleJump",
	"Run": "Run",
	"Walk": "Walk",
	"Shoot":"Shoot"
}
var animation_name:String
#player
var states = {
	"Idle": Callable(self, "_idle_state"),
	"Run": Callable(self, "_run_state"),
	"Walk": Callable(self, "_walk_state"),
	"Jump": Callable(self, "_jump_state"),
	"Fall": Callable(self, "_fall_state"),
	#"Attack": funcref(self, "_attack_state"),
}
var current_state: String  = "Idle" # Estado inicial
var current_animation_state: String 
func _ready() -> void:
	#gunz_a_l.visible = false
	#gunz_a_r.visible = false
	gravity = defalut_gravity
	camera = view.get_node("SpringArm3D/Camera")
	
# Functions
func _input(event: InputEvent) -> void:
	pass
var speed_factor:float
var horizontal_velocity:Vector2

func _process(delta: float) -> void:
		horizontal_velocity = Vector2(velocity.x, velocity.z)
		speed_factor = horizontal_velocity.length() / movement_speed / delta
		
func _physics_process(delta: float)->void:
	# Movement
	if states.has(current_state):
		states[current_state].call(delta)
	# Handle functions
	handle_controls(delta)
	handle_effects(delta)
	# Rotation

	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	
	velocity.x = applied_velocity.x
	velocity.z = applied_velocity.z
	velocity.y -= gravity * delta
	move_and_slide()

	# Rotation
	
	# Falling/respawning

	if position.y < -10:
		get_tree().reload_current_scene()

	# Animation for scale (jumping and landing)
	model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 8)

# Handle animation(s)
# Cambia el estado de la animación.
func change_anim_move_state(new_state: String) -> void:
	if current_animation_state != new_state:  # Solo cambiar si es diferente
		if animation_states.has(new_state):
			var target_index = animation_states[new_state]
			#print("target: ",target_index,"current animation :",animation_tree.get("parameters/Transition/current_state"))
			if target_index != animation_tree.get("parameters/Transition/current_state"):
				current_animation_state = new_state
				animation_tree.set("parameters/Transition/transition_request", target_index)

		else:
			print("No se encontró el estado:", new_state, "en el diccionario")
	
#func play_shoot_anim() -> void:
	#if not animation_tree.get("parameters/Shoot/active"):
		#animation_tree.set("parameters/Shoot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		#
#func stop_shoot_anim() -> void:
	#if animation_tree.get("parameters/Shoot/active"):
		#animation_tree.set("parameters/Shoot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
		#
		
func handle_effects(delta):
	particles_trail.emitting = false
	sound_footsteps.stream_paused = true

	if is_on_floor():
		if speed_factor > 0.05:
			if speed_factor > 0.2:
				sound_footsteps.stream_paused = false
				sound_footsteps.pitch_scale = speed_factor

			if speed_factor > 0.75:
				particles_trail.emitting = true



# Handle movement input

func handle_controls(delta):
	input.x = input_keyboard.x
	input.z = input_keyboard.y
	
	input = input.rotated(Vector3.UP,view.rotation.y)
	
	if input.length() > 1:
		input = input.normalized()
		
	movement_velocity = input * movement_speed * delta
# Collecting coins

func collect_coin():
	coins += 1
	coin_collected.emit(coins)
	
# Ejemplo de estado Idle
func _idle_state(delta: float) -> void:
	input_keyboard = Vector2.ZERO
	jump_single = false
	jump_double = false
	gravity = defalut_gravity
	change_anim_move_state("Idle")
	if (
		Input.is_action_pressed(move_left) or 
		Input.is_action_pressed(move_right) or
		Input.is_action_pressed(move_forward) or
		Input.is_action_pressed(move_backward) 
		):
		change_state("Walk")
	elif Input.is_action_pressed(jump):
		change_state("Jump")
		

func _run_state(delta: float) -> void:
	check_player_move_input(delta) #aseguramos primero verificar las entradas 
	#del teclado antes de cambiar de estado
	# Revisar si se ha dejado de presionar alguna tecla de movimiento
	if speed_factor > 0.2 and is_on_floor():
		change_anim_move_state("Run")
		
	if Input.is_action_pressed(jump):
		change_state("Jump")
	
	elif not (
		Input.is_action_pressed(move_left) or 
		Input.is_action_pressed(move_right) or
		Input.is_action_pressed(move_forward) or
		Input.is_action_pressed(move_backward) 
		):
		change_state("Idle")
		
func _walk_state(delta: float) -> void:
	check_player_move_input(delta) #aseguramos primero verificar las entradas 
	#del teclado antes de cambiar de estado
	# Revisar si se ha dejado de presionar alguna tecla de movimiento
	if speed_factor > 0.2 and is_on_floor():
		change_anim_move_state("Walk")
		
	if Input.is_action_pressed(jump):
		change_state("Jump")
	
	elif not (
		Input.is_action_pressed(move_left) or 
		Input.is_action_pressed(move_right) or
		Input.is_action_pressed(move_forward) or
		Input.is_action_pressed(move_backward) 
		):
		change_state("Idle")
		
func _jump_state(delta: float)-> void:
	check_player_move_input(delta)
	if not jump_single and is_on_floor():
		Audio.play("res://sounds/jump.ogg")
		change_anim_move_state("Jump")
		velocity.y = jump_strength * delta
		model.scale = Vector3(0.5, 1.5, 0.5)
		jump_single = true
		
	#elif Input.is_action_just_pressed(jump) and (not jump_double):
		#Audio.play("res://sounds/jump.ogg")
		##change_collision_shape("flipped")
		#change_anim_move_state("DoubleJump")
		#gravity = double_jump_gravity
		#velocity.y = double_jump_strength * delta
		#model.scale = Vector3(0.7, 1.3, 0.7)
		#jump_double = true
	

	if not is_on_floor() and velocity.y < 0:
		change_state("Fall")


		
func _fall_state(delta: float)->void:
	check_player_move_input(delta)
	change_anim_move_state("Fall")
	#animacion al caer se escala en todos los ejese
	#se reproduce el sodido cuando toca el piso
	if is_on_floor():
		model.scale = Vector3(1.3, 0.75, 1.3)
		Audio.play("res://sounds/land.ogg")
		#change_collision_shape("standing")
		change_state("Idle")
		jump_single = false
		jump_double = false
		gravity = defalut_gravity
		
	#elif Input.is_action_just_pressed(jump) and (not jump_double):
		#Audio.play("res://sounds/jump.ogg")
		##change_collision_shape("flipped")
		#change_anim_move_state("DoubleJump")
		#gravity = double_jump_gravity
		#velocity.y = double_jump_strength * delta
		#model.scale = Vector3(0.7, 1.3, 0.7)
		#jump_double = true

		
# Ejemplo de cambio de estado
func change_state(new_state: String) -> void:
	exit_state(current_state)
	current_state = new_state
	
func exit_state(state: String) -> void:
	#limpiar estados
#	match state:
#		"Idle":
#			print("saliendo de Idle")
#		"Run":
#			print("saliendo de Run")
#		"Jump":
#			print("saliendo de Jump")
#		"Fall":
#			print("saliendo de fall")
	pass
	
#func change_collision_shape(state):
	#if state == "standing":
		#standing_shape.disabled = false
		#standing_shape_leg.disabled = false
		#flipped_shape.disabled = true
		#flipped_shape_leg.disabled = true
	#elif state == "flipped":
		#standing_shape.disabled = true
		#standing_shape_leg.disabled = true
		#flipped_shape.disabled = false
		#flipped_shape_leg.disabled = false
	#else:
		#print("escriva una estado valido ",state)

func check_player_move_input(delta):
	"""FUNCION PARA GESTIONAR LAS ENTRADAS DEL TECLADO"""
	if Input.is_action_pressed(move_left):
		rotation.y = lerp_angle(rotation.y, (view.rotation.y + deg_to_rad(90)), delta * 10)
		input_keyboard.x = 1
	elif Input.is_action_pressed(move_right):
		rotation.y = lerp_angle(rotation.y, (view.rotation.y - deg_to_rad(90)), delta * 10)
		input_keyboard.x = -1
	if Input.is_action_pressed(move_forward):
		rotation.y = lerp_angle(rotation.y, view.rotation.y, delta * 10)
		input_keyboard.y = 1
	elif Input.is_action_pressed(move_backward):
		input_keyboard.y = -1
		rotation.y = lerp_angle(rotation.y, (view.rotation.y - deg_to_rad(180)), delta * 10)
	if Input.is_action_just_released(move_left):
		input_keyboard.x = 0
	elif Input.is_action_just_released(move_right):
		input_keyboard.x = 0
	if Input.is_action_just_released(move_forward):
		input_keyboard.y = 0
	elif Input.is_action_just_released(move_backward):
		input_keyboard.y = 0

func collect_door_key():
	print("llaves")
 
