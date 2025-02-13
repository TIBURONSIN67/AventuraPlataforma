extends Node3D
class_name Oscillator

@export var _character: CharacterBody3D

var _speed: float = 5.0
var _direction: Vector3 = Vector3.FORWARD
var _distance: float = 5.0

var _start_position: Vector3
var _moving_to_target: bool = true
var _traveled_distance: float = 0.0

func _ready():
	if _character == null:
		push_error("Oscillator: No se asignó un CharacterBody3D.")
		return
	
	_start_position = _character.global_position

func _physics_process(delta: float) -> void:
	if _character == null:
		return

	# Movimiento basado en velocidad y delta
	var movement_step = _speed * delta
	_traveled_distance += movement_step if _moving_to_target else -movement_step

	# Verificar si alcanzó los límites
	if _traveled_distance >= _distance:
		_traveled_distance = _distance
		_moving_to_target = false

	elif _traveled_distance <= 0:
		_traveled_distance = 0
		_moving_to_target = true

	# Calcular la nueva posición en relación al padre
	var local_direction = _direction.normalized()
	var transformed_direction = global_transform.basis * local_direction  # Transformamos la dirección local al espacio global del padre

	# Calcular la nueva posición exacta
	var new_position = _start_position + transformed_direction * _traveled_distance
	_character.global_position = new_position

# Métodos para cambiar valores dinámicamente
func set_direction(dir:Vector3):
	_direction = dir.normalized()

func set_speed(speed:float):
	_speed = speed

func set_distance(distance: float):
	_distance = distance
