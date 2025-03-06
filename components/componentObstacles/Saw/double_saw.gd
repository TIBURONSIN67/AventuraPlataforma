class_name DoubleSaw
extends Node3D

@export var oscillator1:Oscillator = null
@export var oscillator2:Oscillator = null

@export_group("Saw1")
@export var speed_saw1:float = 1.0
@export var distance_saw1:float = 1.0
@export var direction_saw1:Vector3 = Vector3.FORWARD


@export_group("Saw2")
@export var speed_saw2:float = 1.0
@export var distance_saw2:float = 1.0
@export var direction_saw2:Vector3 = Vector3.FORWARD

@onready var animation_player1: AnimationPlayer = $"CharacterBody3D/Sierra Circular/AnimationPlayer"
@onready var animation_player2: AnimationPlayer = $"CharacterBody3D2/Sierra Circular/AnimationPlayer"

func _ready() -> void:
	oscillator1.set_direction(direction_saw1)
	oscillator1.set_distance(distance_saw1)
	oscillator1.set_speed(speed_saw1)
	
	oscillator2.set_direction(direction_saw2)
	oscillator2.set_distance(distance_saw2)
	oscillator2.set_speed(speed_saw2)
	
	animation_player1.play("Rotation")
	animation_player2.play("Rotation")
