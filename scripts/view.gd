extends Node3D

@export_group("Properties")
@export var target = CharacterBody3D
@export_group("Zoom")
@export var zoom_minimum = 15
@export var zoom_maximum = 1

@export_group("Rotation")
@export var rotation_speed = 10
@export_group("Inputs")
@export var move_up:String = "v1_up"
@export var move_down:String = "v1_down"
@export var move_left:String = "v1_left"
@export var move_right:String = "v1_right"

var camera_rotation:Vector3
var zoom = 7
var zoom_direction:int = 0

@onready var spring_arm = $SpringArm3D
var touch_pos:Vector2
var touch_sens = 70

@onready var is_local_player = false  # Variable para identificar al jugador local

func _ready():
	if is_local_player:
		position = target.position
		camera_rotation = global_rotation_degrees # Inicializar rotación


func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		var screen_width = get_viewport().get_visible_rect().size.x
		if event.position.x > screen_width / 2:
			touch_pos = event.relative


func _physics_process(delta):
	# Set position and rotation to targets
	#inportante tener esto el posision local y no global
	position.x = lerp(position.x, target.position.x, delta * 10)
	position.z = lerp(position.z, target.position.z, delta * 10)
	position.y = lerp(position.y, target.position.y, delta * 6)
	rotation_degrees = lerp(rotation_degrees,camera_rotation, delta * 30)
	spring_arm.spring_length = lerp(spring_arm.spring_length, float(zoom), 5 * delta)

	handle_input(delta)

# Handle input

func handle_input(delta):
	touch_pos = touch_pos.normalized()
	camera_rotation.y -= touch_pos.x * delta * touch_sens
	camera_rotation.x += touch_pos.y * delta * touch_sens
	camera_rotation.x = clamp(camera_rotation.x, -10, 80)
	
	touch_pos = Vector2.ZERO
	# Zooming
	
