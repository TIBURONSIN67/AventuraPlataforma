extends Node3D

@export_group("Properties")
@export var target = CharacterBody3D
@export_group("Zoom")
@export var zoom_minimum = 15
@export var zoom_maximum = 1

@export_group("Rotation")

var camera_rotation:Vector3
var zoom = 7
var zoom_direction:int = 0

@onready var spring_arm = $SpringArm3D
var touch_pos:Vector2


@onready var is_local_player = false  # Variable para identificar al jugador local

# Variables de suavizado
var input:Vector2 = Vector2.ZERO
@export var touch_sens_y = 135
@export var touch_sens_x = 140

func _ready():
	if is_local_player:
		position = target.position
		camera_rotation = global_rotation_degrees  # Inicializar rotación

var normalized_touch:Vector2
func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		var screen_width = get_viewport().get_visible_rect().size.x
		if event.position.x > screen_width / 2:
			touch_pos.x = event.relative.x / (get_viewport().get_visible_rect().size.x / 2)
			touch_pos.y = event.relative.y / (get_viewport().get_visible_rect().size.y)

func _physics_process(delta):
	# Set position and rotation to targets
	position.x = lerp(position.x, target.position.x, delta * 10)
	position.z = lerp(position.z, target.position.z, delta * 10)
	position.y = lerp(position.y, target.position.y, delta * 6)

	# Suavizamos la rotación con lerp
	rotation_degrees = camera_rotation
	
	spring_arm.spring_length = lerp(spring_arm.spring_length, float(zoom), 5 * delta)

	handle_input(delta)

# Handle input

func handle_input(delta):
	# Suavizamos la rotación con el toque
	input.x -= touch_pos.x * touch_sens_x
	input.y += touch_pos.y * touch_sens_y

	# Inercia en la rotación (suavizado)
	camera_rotation.x = lerp(camera_rotation.x, input.y, delta * 20)
	camera_rotation.y = lerp(camera_rotation.y, input.x, delta * 20)
	
	camera_rotation.x = clamp(camera_rotation.x,-10,90)

	touch_pos = Vector2.ZERO
