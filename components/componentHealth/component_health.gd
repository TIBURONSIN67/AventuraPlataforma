class_name Health
extends Node

signal is_dead
signal updated_health(current: float, min: float, max: float)

@export var health_progres_bar: TextureProgressBar = null
@export var max_health: float = 100.0
@export var min_health: float = 0.0

# Atributos privados
var _max_health: float = 0.0
var _min_health: float = 0.0
var _current_health: float = 0.0

func _ready() -> void:
	# Inicializar la salud al máximo
	_max_health = max_health
	_min_health = min_health
	_current_health = _max_health
	update_health()

# Métodos de acceso y modificación
func set_max_health(value: float) -> void:
	if value > 0.0:
		_max_health = value
		_current_health = clamp(_current_health, _min_health, _max_health)
		update_health()

func get_max_health() -> float:
	return _max_health

func set_min_health(value: float) -> void:
	if value >= 0.0:
		_min_health = value
		_current_health = clamp(_current_health, _min_health, _max_health)
		update_health()

func get_min_health() -> float:
	return _min_health

func set_current_health(value: float) -> void:
	_current_health = clamp(value, _min_health, _max_health)
	if _current_health <= _min_health:
		is_dead.emit()
	update_health()

func get_current_health() -> float:
	return _current_health

# Métodos de interacción
func take_damage(damage: float) -> void:
	if damage > 0.0:
		set_current_health(_current_health - damage)


func heal(amount: float) -> void:
	if amount > 0.0:
		set_current_health(_current_health + amount)

func update_health() -> void:
	if health_progres_bar != null:
		health_progres_bar.value = (_current_health / _max_health) * 100.0
	updated_health.emit(_current_health, min_health , _max_health)
