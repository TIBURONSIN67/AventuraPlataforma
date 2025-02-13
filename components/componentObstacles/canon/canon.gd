class_name Canon extends Node3D

@onready var direction: Marker3D = $Direction
@export var component_shoot: Shoot = null
@onready var animation_player: AnimationPlayer = $"StaticBody3D/Model/cañon/AnimationPlayer"

@export var coldawn:float = 1
@export var damage:float = 10.0
var dir:Vector3

func _ready() -> void:
	dir = global_position.direction_to(direction.global_position)
	animation_player.play("KeyAction")
	component_shoot.set_damage(damage)
	animation_player.speed_scale = coldawn
	
func shoot():
	component_shoot.instant_shoot(dir)
	
