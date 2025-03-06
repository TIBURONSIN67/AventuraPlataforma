
class_name  OscillatorPlatform
extends Node3D

@export var direction:Vector3 = Vector3.FORWARD
@export var distance:float = 15.0
@export var speed:float = 1.0
@export var oscillator:Oscillator = null

func _ready() -> void:
	oscillator.set_direction(direction)
	oscillator.set_distance(distance)
	oscillator.set_speed(speed)
	
