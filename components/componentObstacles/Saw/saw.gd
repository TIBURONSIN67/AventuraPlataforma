class_name Saw
extends Node3D

@export var oscillator:Oscillator = null
@export var speed:float = 1.0
@export var distance:float = 1.0
@export var direction:Vector3 = Vector3.FORWARD

@onready var animation_player: AnimationPlayer = $"CharacterBody3D/Sierra Circular/AnimationPlayer"

func _ready() -> void:
	oscillator.set_direction(direction)
	oscillator.set_distance(distance)
	oscillator.set_speed(speed)
	animation_player.play("Rotation")
