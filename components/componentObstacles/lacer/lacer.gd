class_name Lacer extends Node3D

@export var oscillator:Oscillator = null

@export var speed:float = 1.0
@export var distance:float = 1.0
@export var direction:Vector3 = Vector3.FORWARD

func _ready() -> void:
	oscillator.set_direction(direction)
	oscillator.set_distance(distance)
	oscillator.set_speed(speed)
