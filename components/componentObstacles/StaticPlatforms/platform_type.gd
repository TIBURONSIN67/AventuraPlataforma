extends Node3D

class_name TypePlatform

@export var falling_platform: FallingPlatform = null  # Plataforma que cae
@export var is_falling_platform: bool = false  # Si la plataforma debe caer o no

@export var _platform: CharacterBody3D  # Plataforma que se usará

@onready var _model: Node3D = $CharacterBody3D/Model

@onready var _falling_model:Node3D = $"CharacterBody3D/Model/plataforma que cae"
@onready var _static_model:Node3D = $"CharacterBody3D/Model/plataforma estandar"

@onready var _fall_collision_shape: CollisionShape3D = $CharacterBody3D/FallCollisionShape
@onready var _static_collision_shape: CollisionShape3D = $CharacterBody3D/StaticCollisionShape

func _ready():
	# Configurar la plataforma dependiendo de si debe caer o no
	if is_falling_platform:
		# Inicializar la plataforma de caída
		falling_platform.platform = _platform
		falling_platform.restart.connect(_on_platform_restart)
		_falling_model.visible = true
		_static_model.queue_free()
		_static_collision_shape.queue_free()
		# Configurar la plataforma para que pueda caer

	else:
		# Plataforma estática, sin caer
		falling_platform.queue_free()
		_static_model.visible = true
		_falling_model.queue_free()
		_fall_collision_shape.queue_free()


func _on_platform_restart():
	pass
