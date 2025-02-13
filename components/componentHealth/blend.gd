class_name Blend
extends Node3D

@onready var timer: Timer = $Timer

@export var health: Health = null
@export var damage_amount: float = 1  # Daño por sangrado
@export var bleed_interval: float = .1  # Intervalo de tiempo en segundos para el sangrado

func _ready() -> void:
	timer.wait_time = bleed_interval  # Configura el tiempo de espera del timer
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	if health:
		health.take_damage(damage_amount)  # Aplica el daño al personaje
