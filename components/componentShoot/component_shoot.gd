class_name Shoot extends Node3D

signal shooting

@export var bullet_scene: PackedScene = null
var bullet_a: BulletA

@onready var timer: Timer = $Timer
var can_shoot = false
var cooldown_shoot: float  = .1  # Tiempo de enfriamiento entre disparos
@onready var shoot_point: Marker3D = $Marker3D
var current_timer = false
var bullet_speed:float = 10
var damage:float = 10.0

func _ready() -> void:
	timer.timeout.connect(_timeout)
	timer.wait_time = cooldown_shoot  # Configura el tiempo de enfriamiento

func instant_shoot(direction: Vector3):
		shooting.emit()
		bullet_a = bullet_scene.instantiate()
		get_tree().root.add_child(bullet_a)
		bullet_a.set_speed(bullet_speed)
		bullet_a.set_damage(damage)
		bullet_a._shoot(direction,shoot_point.global_position)
		
func shoot(direction: Vector3):
	if not current_timer:
		timer.start()
		current_timer = true
		
	if can_shoot:
		# Solo permite disparar si el temporizador no está en ejecución
		shooting.emit()
		bullet_a = bullet_scene.instantiate()
		get_tree().root.add_child(bullet_a)
		bullet_a._shoot(direction,shoot_point.global_position)
		can_shoot = false

func stop_shoot():
	# Detiene el temporizador y reinicia la posibilidad de disparar
	timer.stop()
	current_timer = false

func _timeout():
	# Habilita el disparo nuevamente al finalizar el temporizador
	can_shoot = true

func set_bullet_speed(speed:float):
	bullet_speed = speed

func set_damage(d:float):
	damage = d

func set_cooldown_shoot(c:float):
	timer.wait_time = c
