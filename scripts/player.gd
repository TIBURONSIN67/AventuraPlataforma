extends CharacterBody3D

signal coin_collected

@export_subgroup("Components")
@export var view:Node3D
@export var camera:Camera3D
@export_subgroup("Properties")
@export var movement_speed = 250
@export var jump_strength = 500

@onready var custom_tracks: AnimationPlayer = $CustomTracks

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
var is_mele_atack = false
@onready var virtual_joystick: VirtualJoystick = $"GUI_player/HBoxContainer/Virtual Joystick"

#INPUT
var input:Vector3 = Vector3.ZERO
var input_keyboard:Vector2 = Vector2.ZERO

var jump_single: bool = false
var is_shooting = false
var coins = 0

@onready var particles_trail = $ParticlesTrail
@onready var sound_footsteps = $audio
@onready var take_damage_sound: AudioStreamPlayer3D = $TakeDamageSound
@onready var model:Node3D = $Character
@onready var animation_tree:AnimationTree = $AnimationTree



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
	
var speed_factor:float
var horizontal_velocity:Vector2

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	
func _ready() -> void:
	if not is_multiplayer_authority(): return
	gravity = defalut_gravity
	Network.request_damage_signal.connect(request_damage)


func _process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	camera.current = true
	horizontal_velocity = Vector2(velocity.x, velocity.z)
	speed_factor = horizontal_velocity.length() / movement_speed / delta
	
	if Network.players[multiplayer.get_unique_id()]["health"] <= 0:
		global_position = Vector3(0,20,0)
		rpc_id(1,"restart_healt")
		
func request_damage(target_id: int, damage: float):
	if Network.players.has(target_id) and multiplayer.is_server():
		_apply_damage(target_id, damage)
		
func _apply_damage(target_id: int, damage: float):
	if Network.players.has(target_id) and multiplayer.is_server():
		Network.players[target_id]["health"] -= damage
		Network.players[target_id]["node"].take_damage_sound.play()
		if Network.players[target_id]["health"] <= 0:
			Network.players[target_id]["health"] = 0
			print("Player", target_id, "has been defeated!")

		# Notifica a todos los clientes sobre el nuevo estado de salud
		rpc("update_health",target_id,Network.players[target_id]["health"])
		
@rpc("call_local")
func restart_healt():
	var id =  multiplayer.get_remote_sender_id()
	Network.players[id]["health"] = 100
	rpc("update_health",id,Network.players[id]["health"])

@rpc("any_peer", "reliable")
func update_health(id:int,new_health: float):
	if Network.players.has(id):
		Network.players[id]["health"] = new_health
		print("Player ", id, " salud actualizada ", new_health)

func _physics_process(delta: float)->void:
	if not is_multiplayer_authority(): return
	if states.has(current_state):
		states[current_state].call(delta)
	# Handle functions
	handle_controls(delta)
	handle_effects(delta)
	# Rotation

	applied_velocity = velocity.lerp(movement_velocity, delta * 10)

	if not is_mele_atack:
		velocity.x = applied_velocity.x
		velocity.z = applied_velocity.z
	elif  is_mele_atack:
		velocity.x = applied_velocity.x * 95 / 100
		velocity.z = applied_velocity.z * 95 / 100
		
	velocity.y -= gravity * delta
	move_and_slide()
	
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
	
func handle_effects(_delta):
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
	if input.length() > 1:
		input = input.normalized()
		
	movement_velocity = input * movement_speed * delta
	
# Ejemplo de estado Idle
func _idle_state(delta: float) -> void:
	check_mele_atack_input(delta)
	input.x = 0
	input.z = 0
	jump_single = false
	gravity = defalut_gravity
	change_anim_move_state("Idle")
	if (virtual_joystick.is_pressed):
		change_state("Walk")
	elif Input.is_action_pressed(jump):
		change_state("Jump")
		

func _run_state(delta: float) -> void:
	check_mele_atack_input(delta)
	check_player_move_input(delta) #aseguramos primero verificar las entradas 
	#del teclado antes de cambiar de estado
	# Revisar si se ha dejado de presionar alguna tecla de movimiento
	if speed_factor > 0.2 and is_on_floor():
		change_anim_move_state("Run")
		
	if Input.is_action_pressed(jump):
		change_state("Jump")
	
	elif not (virtual_joystick.is_pressed):
		change_state("Idle")
		
func _walk_state(delta: float) -> void:
	check_mele_atack_input(delta)
	check_player_move_input(delta) #aseguramos primero verificar las entradas 
	#del teclado antes de cambiar de estado
	# Revisar si se ha dejado de presionar alguna tecla de movimiento
	if speed_factor > 0.2 and is_on_floor():
		change_anim_move_state("Walk")
		
	if Input.is_action_pressed(jump):
		change_state("Jump")
	
	elif not (virtual_joystick.is_pressed):
		change_state("Idle")
		
func _jump_state(delta: float)-> void:
	check_mele_atack_input(delta)
	check_player_move_input(delta)
	if not jump_single and is_on_floor():
		Audio.play("res://sounds/jump.ogg")
		change_anim_move_state("Jump")
		velocity.y = jump_strength * delta
		model.scale = Vector3(0.5, 1.5, 0.5)
		jump_single = true
		

	if not is_on_floor() and velocity.y < 0:
		change_state("Fall")


		
func _fall_state(delta: float)->void:
	check_player_move_input(delta)
	check_mele_atack_input(delta)
	change_anim_move_state("Fall")
	#animacion al caer se escala en todos los ejese
	#se reproduce el sodido cuando toca el piso
	if is_on_floor():
		model.scale = Vector3(1.3, 0.75, 1.3)
		Audio.play("res://sounds/land.ogg")
		#change_collision_shape("standing")
		change_state("Idle")
		jump_single = false
		gravity = defalut_gravity
		
		
# Ejemplo de cambio de estado
func change_state(new_state: String) -> void:
	exit_state(current_state)
	current_state = new_state
	
func exit_state(_state: String) -> void:
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
	


func check_player_move_input(delta):
	"""Función para gestionar las entradas del joystick."""
	if virtual_joystick.is_pressed:
		input.x = virtual_joystick.output.x * -1
		input.z = virtual_joystick.output.y * -1
		input = input.rotated(Vector3.UP, view.rotation.y)
		rotation.y = lerp_angle(rotation.y, atan2(input.x, input.z), delta * 10)
	else:
		input = Vector3.ZERO

func check_mele_atack_input(delta):
	if Input.is_action_pressed("Mele"):
		play_anim_mele_atack()
		is_mele_atack = true
		rotation.y = lerp_angle(rotation.y, view.rotation.y, delta * 10)
		
	if Input.is_action_just_released("Mele"):
		is_mele_atack = false
		
		
func play_anim_mele_atack():
	if not animation_tree.get("parameters/Mele/active"):
		custom_tracks.play("Atack")
		animation_tree.set("parameters/Mele/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		

	
