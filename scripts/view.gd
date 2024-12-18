extends Node3D

@export_group("Properties")
@export var target = CharacterBody3D
@export_group("Zoom")
@export var zoom_minimum = 5
@export var zoom_maximum = 1
@export var zoom_speed = 250

@export_group("Rotation")
@export var rotation_speed = 10
@export var keyboard_rotation_speed = 60
@export_group("Inputs")
@export var move_up:String = "v1_up"
@export var move_down:String = "v1_down"
@export var move_left:String = "v1_left"
@export var move_right:String = "v1_right"

var camera_rotation:Vector3
var zoom = 5
var zoom_direction:int = 0

@onready var spring_arm = $SpringArm3D
var input := Vector2.ZERO
var keyboard_input := Vector3.ZERO
var mous_pos:Vector2

func _ready():
	position = target.position
	camera_rotation = global_rotation_degrees # Initial rotation
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mous_pos = event.relative
		
	elif event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_direction = 1
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_direction = -1
				


func _physics_process(delta):
	
	# Set position and rotation to targets
	#inportante tener esto el posision local y no global
	position = lerp(position, target.position, delta * 10)
	rotation_degrees = lerp(rotation_degrees,camera_rotation, delta * 15)
	spring_arm.spring_length = lerp(spring_arm.spring_length, float(zoom), 5 * delta)

	handle_input(delta)

# Handle input

func handle_input(delta):
	#input = mous_pos
	#camera_rotation -= (Vector3(input.y, input.x, 0) * rotation_speed)* delta
	#camera_rotation.x = clamp(camera_rotation.x, -80, -10)
	#mous_pos = Vector2.ZERO
	
	"""CONTROL CAMARA CON TECLADO"""
	keyboard_input.y = Input.get_axis(move_left, move_right)
	keyboard_input.x = Input.get_axis(move_up, move_down)
	
	camera_rotation -= keyboard_input.limit_length(1.0) * keyboard_rotation_speed * delta
	camera_rotation.x = clamp(camera_rotation.x, -15, 80)
	# Zooming
	
	zoom += zoom_direction * zoom_speed * delta
	zoom_direction = 0
	zoom = clamp(zoom, zoom_maximum, zoom_minimum)
	
