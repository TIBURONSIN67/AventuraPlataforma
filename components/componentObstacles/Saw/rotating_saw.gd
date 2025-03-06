
class_name RotatingSaw 
extends Node3D

@export var rotation_speed: float = 1.0  # Velocidad de rotación en grados por segundo
@export var rotation_axis: Vector3 = Vector3.UP  # Eje de rotación

@export var character:CharacterBody3D = null
@onready var oscillator: Oscillator = $Oscillator

@export var distance:float = 4
@export var direction:Vector3 = Vector3.FORWARD
@export var move_speed:float = 1.0

@export var move:bool = false

func _process(delta: float) -> void:
	if move:
		oscillator.set_direction(direction)
		oscillator.set_distance(distance)
		oscillator.set_speed(move_speed)
	else:
		oscillator.set_distance(0)
	character.rotate(rotation_axis.normalized(), rotation_speed * delta)
