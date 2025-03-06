# Clase principal del jugador que hereda de CharacterBody3D
class_name Player extends CharacterBody3D

# Exportación de propiedades y componentes del jugador
@export_subgroup("Components")
@export var view: Node3D  # Vista del jugador

# Propiedades relacionadas con el movimiento
@export_subgroup("Properties")
@export var movement_speed = 250  # Velocidad de movimiento
@export var jump_strength = 500  # Fuerza de salto
@onready var coyote_timer: Timer = $CoyoteTimer
@export var coyote_time_duration: float = 0.2  # Duración del Coyote Time

# Entradas de control (movimiento y salto)
@export_subgroup("Inputs")
@export var move_left: String = "left"
@export var move_right: String = "right"
@export var move_forward: String = "forward"
@export var move_backward: String = "backward"
@export var jump: String = "jump"

# Variables internas de movimiento
var movement_velocity: Vector3
var rotation_direction: float
var gravity
var default_gravity = 23  # Gravedad por defecto
var double_jump_gravity = 17  # Gravedad durante un doble salto
var can_jump: bool = true
# Variables para ataques cuerpo a cuerpo
@export_subgroup("Others")
var is_melee_attack = false  # Si el jugador está atacando cuerpo a cuerpo
@export var virtual_joystick: VirtualJoystick = null
@export var Jump_sound: AudioStreamPlayer3D  # Sonido de salto
@export var land_sound: AudioStreamPlayer3D  # Sonido al aterrizar

# Variables de entrada para el control de movimiento
var input: Vector3 = Vector3.ZERO
var input_keyboard: Vector2 = Vector2.ZERO

# Variables de salto y estado del jugador
var jump_single: bool = false  # Para controlar el salto simple
var is_shooting = false  # Si el jugador está disparando
var dead: bool = false  # Si el jugador está muerto

@export var particles_trail:CPUParticles3D = null
@export var walk_audio:AudioStreamPlayer3D = null
@export var character: Node3D = null
@export var animation_tree: AnimationTree = null

# Velocidad aplicada y máquina de estados
var applied_velocity: Vector3
var animation_states = {
	"Idle": "Idle",
	"Dead": "Dead",
	"NotDead": "NotDead",
	"Jump": "Jump",
	"Fall": "Fall",
	"DoubleJump": "DoubleJump",
	"Walk": "Walk",
	"Shoot": "Shoot"
}
var animation_name: String

# Diccionario de estados de la máquina de estados
var states = {
	"Idle": Callable(self, "_idle_state"),
	"Walk": Callable(self, "_walk_state"),
	"Jump": Callable(self, "_jump_state"),
	"Fall": Callable(self, "_fall_state"),
	"Dead": Callable(self, "_dead_state"),
}
@export var gui_player: Control
# Estado actual y animación
var current_state: String = "Idle"
var current_animation_state: String = "Idle"
var speed_factor: float
var horizontal_velocity: Vector2

# Método _ready se ejecuta cuando el nodo está listo
func _ready() -> void:
	gravity = default_gravity  # Inicialización de gravedad
	
	coyote_timer.wait_time = coyote_time_duration
	coyote_timer.timeout.connect(_timeout_coyote_time)
# Método _process se ejecuta cada frame
func _process(delta: float) -> void:
	horizontal_velocity = Vector2(velocity.x, velocity.z)  # Actualización de velocidad horizontal
	speed_factor = horizontal_velocity.length() / movement_speed / delta


# Método _physics_process para la física y movimiento
func _physics_process(delta: float) -> void:
	if states.has(current_state):
		states[current_state].call(delta)  # Llamar al estado actual
			# Manejo de controles y efectos
	handle_controls(delta)
	handle_effects(delta)
			# Rotación y movimiento del jugador
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	if not is_melee_attack:
		velocity.x = applied_velocity.x
		velocity.z = applied_velocity.z
	elif is_melee_attack:
		velocity.x = applied_velocity.x * 95 / 100
		velocity.z = applied_velocity.z * 95 / 100
	velocity.y -= gravity * delta
	move_and_slide()  # Movimiento y deslizamiento de la física
			# Animación para la escala (salto y aterrizaje)
	character.scale = character.scale.lerp(Vector3(1, 1, 1), delta * 8)

func change_anim_move_state(new_state: String) -> void:
	if current_animation_state == new_state:
		return  # No cambiar si ya estamos en el mismo estado
	
	if not animation_states.has(new_state):
		print("No se encontró el estado:", new_state, "en el diccionario")
		return
	
	var target_index = animation_states[new_state]
	var transition_path = "parameters/Transition/transition_request"
	
	# Manejo de casos especiales
	match target_index:
		"Jump":
			if not animation_tree.get("parameters/Jump/active"):
				animation_tree.set("parameters/Jump/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		"Dead", "NotDead":
			transition_path = "parameters/Transition2/transition_request"
			if animation_tree.get("parameters/Transition2/current_state") != target_index:
				animation_tree.set(transition_path, target_index)
		_:
			# Transición estándar
			if target_index != animation_tree.get("parameters/Transition/current_state"):
				animation_tree.set(transition_path, target_index)
	
	# Actualizar el estado solo si se realizó la transición
	current_animation_state = new_state


# Manejo de efectos (partículas y sonido)
func handle_effects(_delta):
	particles_trail.emitting = false
	walk_audio.stream_paused = true

		# Efectos al estar en el suelo
	if is_on_floor():
		if speed_factor > 0.05:
			if speed_factor > 0.2:
				walk_audio.stream_paused = false
				walk_audio.pitch_scale = speed_factor
			if speed_factor > 0.75:
				particles_trail.emitting = true

# Manejo de controles del jugador (movimiento)
func handle_controls(delta):
	if input.length() > 1:
		input = input.normalized()  # Normalizar la dirección del movimiento

	if input.length() >= 0.5:
		movement_velocity = input * movement_speed * delta
	else:
		movement_velocity = Vector3.ZERO  # Detener el movimiento si la entrada es pequeña

# Ejemplo de estado "Idle" (inactivo)
func _idle_state(delta: float) -> void:
	if not is_on_floor() and not ray_cast.is_colliding():
		can_jump = true
		change_state("Fall")
		return
	input.x = 0
	input.z = 0
	jump_single = false
	gravity = default_gravity
	change_anim_move_state("Idle")

	if virtual_joystick.is_pressed or _check_pc_inputs():
		change_state("Walk")
		return
	elif Input.is_action_pressed(jump):
		change_state("Jump")
		return

# Función para verificar las entradas del teclado (PC)
func _check_pc_inputs() -> bool:
	return (
		Input.is_action_pressed(move_left) or
		Input.is_action_pressed(move_right) or
		Input.is_action_pressed(move_forward) or
		Input.is_action_pressed(move_backward)
	)

# Estado de caminar
func _walk_state(delta: float) -> void:
	if not is_on_floor() and not ray_cast.is_colliding():
		can_jump = true
		change_state("Fall")
		return
	check_player_move_input(delta)

	if speed_factor > 0.2 and is_on_floor():
		change_anim_move_state("Walk")

	if Input.is_action_pressed(jump):
		change_state("Jump")
		
	elif not (virtual_joystick.is_pressed or _check_pc_inputs()):
		change_state("Idle")

# Estado de salto
func _jump_state(delta: float) -> void:
	check_player_move_input(delta)

	if not jump_single and (is_on_floor() or can_jump):
		Jump_sound.play()
		change_anim_move_state("Jump")
		velocity.y = jump_strength * delta
		character.scale = Vector3(0.5, 1.5, 0.5)
		jump_single = true
		can_jump = false

	elif not is_on_floor() and velocity.y < 0 and jump_single:
		can_jump = true
		change_state("Fall")

	elif is_on_floor() and jump_single:
		change_state("Idle")


@onready var ray_cast: RayCast3D = $RayCast

# Estado de caída
func _fall_state(delta: float) -> void:
	check_player_move_input(delta)
	change_anim_move_state("Fall")
	
	# Solo iniciar el temporizador si no está corriendo
	if coyote_timer.is_stopped() and can_jump:
		coyote_timer.start()

	if is_on_floor():
		land_effects()
		change_state("Idle")
		return
	
	if Input.is_action_pressed(jump):
		if ray_cast.is_colliding():
			land_effects()
			change_state("Jump")
			return
		elif can_jump:
			change_state("Jump")
			return

func land_effects():
	character.scale = Vector3(1.2, 0.85, 1.2)
	land_sound.play()
	coyote_timer.stop()
	coyote_timer.wait_time = coyote_time_duration
	jump_single = false
	can_jump = true
	gravity = default_gravity #para doble salto 


func _dead_state(delta):
	check_player_move_input(delta)
	change_anim_move_state("Dead")
	dead = true
	
# Cambio de estado
func change_state(new_state: String) -> void:
	exit_state(current_state)
	current_state = new_state

# Salida de estado
func exit_state(_state: String) -> void:
	pass  # Limpiar estados si es necesario

# Comprobación de entrada de movimiento del jugador
func check_player_move_input(delta):
	if PlatformChecker.IsWindows():
		if Input.is_action_pressed("forward"):
			if dead:
				input = Vector3.ZERO
				return
			input.x = 0
			input.z = 1
		elif Input.is_action_pressed("backward"):
			if dead:
				input = Vector3.ZERO
				return
			input.x = 0
			input.z = -1
		if Input.is_action_pressed("left"):
			if dead:
				input = Vector3.ZERO
				return
			input.z = 0
			input.x = 1
		elif Input.is_action_pressed("right"):
			if dead:
				input = Vector3.ZERO
				return
			input.z = 0
			input.x = -1

		if _check_pc_inputs():
			input = input.rotated(Vector3.UP, view.rotation.y)
			rotation.y = lerp_angle(rotation.y, atan2(input.x, input.z), delta * 20)
		else:
			input = Vector3.ZERO

	elif PlatformChecker.IsAndroid():  # Si está en Android
		if virtual_joystick.is_pressed:
			if dead:
				return
			input.x = virtual_joystick.output.x * -1
			input.z = virtual_joystick.output.y * -1
			input = input.rotated(Vector3.UP, view.rotation.y)
			rotation.y = lerp_angle(rotation.y, atan2(input.x, input.z), delta * 20)
		else:
			input = Vector3.ZERO


# Función de muerte del jugador
func _is_dead():
	change_state("Dead")

func _updated_heath(current_health: float, min_health:float, max_health):
	if current_health > min_health and dead:
		dead = false
		change_anim_move_state("NotDead")
		change_state("Idle")
		return
		
func is_player_dead()-> bool:
	return dead

func _timeout_coyote_time():
	can_jump = false
	coyote_timer.stop()
	coyote_timer.wait_time = coyote_time_duration
	print("ya no puedes saltar")
