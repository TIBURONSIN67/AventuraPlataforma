extends Node3D

@export_group("Properties")
@export var target = CharacterBody3D
@export_group("Zoom")
@export var zoom_minimum = 15
@export var zoom_maximum = 1

@export_group("Rotation")

var camera_rotation:Vector3
var zoom = 8
var zoom_direction:int = 0

@onready var spring_arm = $SpringArm3D
var touch_pos:Vector2
var mouse_pos:Vector2

@export var health:Health = null

# Variables de suavizado
var input:Vector2 = Vector2.ZERO
@export var touch_sens_y:float = 135.0
@export var touch_sens_x:float = 140.0

@export var mouse_sens_y:float = .15
@export var mouse_sens_x:float = .25
var normalized_touch:Vector2

var is_dead:bool = false

func _ready():
	position = target.position
	camera_rotation = global_rotation_degrees  # Inicializar rotación
	health.is_dead.connect(_is_entity_dead)
	health.updated_health.connect(_updated_health)
	
	if Platform.is_windows():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event: InputEvent) -> void:
	if Platform.is_android():
		if event is InputEventScreenDrag:
			var screen_width = get_viewport().get_visible_rect().size.x
			if event.position.x > screen_width / 2:
				touch_pos.x = event.relative.x / (get_viewport().get_visible_rect().size.x / 2)
				touch_pos.y = event.relative.y / (get_viewport().get_visible_rect().size.y)
				
	elif  Platform.is_windows():
		if event is InputEventMouseMotion:
			mouse_pos.x = event.relative.x 
			mouse_pos.y = event.relative.y 
			
func _physics_process(delta):
	if is_dead:
		return
	# Set position and rotation to targets
	position.x = lerp(position.x, target.position.x, delta * 10)
	position.z = lerp(position.z, target.position.z, delta * 10)
	position.y = lerp(position.y, target.position.y + .7, delta * 10)

	rotation_degrees = camera_rotation
	
	spring_arm.spring_length = lerp(spring_arm.spring_length, float(zoom), 5 * delta)
	
	if Platform.is_windows():
		handle_input_windows(delta)
	elif Platform.is_android():
		handle_input_android(delta)


func handle_input_windows(delta):
	# Suavizamos la rotación con el toque
	input.x -= mouse_pos.x * mouse_sens_x
	input.y += mouse_pos.y * mouse_sens_y
	# Inercia en la rotación (suavizado)
	camera_rotation.x = lerp(camera_rotation.x, input.y, delta * 20)
	camera_rotation.y = lerp(camera_rotation.y, input.x, delta * 20)
	
	camera_rotation.x = clamp(camera_rotation.x,-10,90)
	mouse_pos = Vector2.ZERO
	
func handle_input_android(delta):
	# Suavizamos la rotación con el toque
	input.x -= touch_pos.x * touch_sens_x
	input.y += touch_pos.y * touch_sens_y
	# Inercia en la rotación (suavizado)
	camera_rotation.x = lerp(camera_rotation.x, input.y, delta * 20)
	camera_rotation.y = lerp(camera_rotation.y, input.x, delta * 20)
	
	camera_rotation.x = clamp(camera_rotation.x,-10,90)
	touch_pos = Vector2.ZERO

func _is_entity_dead():
	is_dead = true

func _updated_health(current_health: float, min: float, max: float):
	if current_health > min:  
		is_dead = false
