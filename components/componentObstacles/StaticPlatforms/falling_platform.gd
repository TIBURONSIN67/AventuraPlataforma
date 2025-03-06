extends Node3D

class_name FallingPlatform
signal restart

"""
Componente para una plataforma que cae cuando es pisada.
Requiere un CharacterBody3D y un Area3D para detectar colisiones.
"""

@export var fall_delay: float = 1  # Tiempo antes de caer
@export var fall_speed: float = 5  # Factor de velocidad de caída
@export var restart_time: float = 5  # Tiempo antes de reiniciarse

@export var platform: CharacterBody3D  # Plataforma que caerá
@export var model: Node3D = null  # Modelo de la plataforma

@onready var trigger_area: Area3D = $TriggerArea  # Detector de colisiones
@onready var timer_fall: Timer = $TimerFall  # Timer para caída
@onready var timer_destroy: Timer = $TimerDestroy  # Timer para reinicio

var _initial_position: Vector3
var _falling: bool = false
var _velocity: Vector3 = Vector3.ZERO
const GRAVITY: float = 9.8  # Simulación de gravedad

var on_body:bool = false

@onready var audio_fall: AudioStreamPlayer3D = $AudioFall

func _ready():
	if not platform or not trigger_area:
		push_error("FallingPlatform: 'platform' o 'trigger_area' no asignado.")
		return

	_initial_position = platform.global_position
	timer_fall.wait_time = fall_delay
	timer_destroy.wait_time = restart_time

	# Conectar señales
	trigger_area.body_entered.connect(_on_body_entered)
	timer_fall.timeout.connect(_start_falling)
	timer_destroy.timeout.connect(_restart_platform)

func _on_body_entered(_body):
	"""
	Inicia la cuenta regresiva para la caída cuando se pisa la plataforma.
	"""
	if _falling:
		return
	on_body = true
	timer_fall.start()

func _start_falling():
	"""
	Activa la caída de la plataforma y deshabilita colisiones.
	"""
	audio_fall.play()
	_falling = true
	timer_fall.stop()
	timer_destroy.start()

func _physics_process(delta):
	"""
	Si la plataforma está cayendo, aplica la gravedad.
	"""
	if _falling:
		_velocity.y -= GRAVITY * fall_speed * delta
		platform.velocity = _velocity
		platform.move_and_slide()

	if on_body:
		model.scale = lerp(model.scale, Vector3(1.15, 1, 1.15), delta * 5)

func _restart_platform():
	"""
	Reinicia la plataforma a su estado original.
	"""
	_falling = false
	timer_destroy.stop()
	_velocity = Vector3.ZERO
	platform.global_position = _initial_position
	on_body = false
	model.scale = Vector3.ONE

	restart.emit()
