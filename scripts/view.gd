extends Node3D

@export_group("Properties")
@export var target = CharacterBody3D
@export_group("Zoom")
@export var zoom_minimum = 15
@export var zoom_maximum = 1

@export_group("Rotation")
@export var rotation_speed = 10

var camera_rotation:Vector3
var zoom = 7
var zoom_direction:int = 0

@onready var spring_arm = $SpringArm3D
var touch_pos:Vector2


@onready var is_local_player = false  # Variable para identificar al jugador local

# Variables de suavizado
var target_rotation: Vector3
var rotation_velocity: Vector3 = Vector3.ZERO
@export var smooth_factor: float = 0.1
@export var touch_sens_y = 25
@export var touch_sens_x = 30

func _ready():
	if is_local_player:
		position = target.position
		camera_rotation = global_rotation_degrees  # Inicializar rotación
		target_rotation = camera_rotation  # Almacenamos la rotación inicial


func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		var screen_width = get_viewport().get_visible_rect().size.x
		if event.position.x > screen_width / 2:
			touch_pos = event.relative


func _physics_process(delta):
	# Set position and rotation to targets
	position.x = lerp(position.x, target.position.x, delta * 10)
	position.z = lerp(position.z, target.position.z, delta * 10)
	position.y = lerp(position.y, target.position.y, delta * 6)

	# Suavizamos la rotación con lerp
	rotation_degrees = lerp(rotation_degrees, target_rotation, delta * 30)
	
	spring_arm.spring_length = lerp(spring_arm.spring_length, float(zoom), 5 * delta)

	handle_input(delta)

# Handle input

func handle_input(delta):
	touch_pos = touch_pos.normalized()

	# Suavizamos la rotación con el toque
	target_rotation.y -= touch_pos.x * rotation_speed * delta * touch_sens_y
	target_rotation.x += touch_pos.y * rotation_speed * delta * touch_sens_x

	# Limitar la rotación en el eje X para evitar giros extremos
	target_rotation.x = clamp(target_rotation.x, -10, 80)

	# Inercia en la rotación (suavizado)
	rotation_velocity = lerp(rotation_velocity, target_rotation - camera_rotation, smooth_factor)
	camera_rotation += rotation_velocity

	touch_pos = Vector2.ZERO

	# Zooming (este puede ser el código que ya tienes para zoom)
