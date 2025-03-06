class_name AgentController
extends Node3D

# Referencias exportadas (públicas para configuración en el editor)
@export var character: CharacterBody3D = null
@export var agent_perception: AgentPerception = null
@onready var _agent: NavigationAgent3D = $NavigationAgent3D
@export var hit_box: HitBox = null
@onready var _timer: Timer = $Timer

# Atributos privados
var _current_state: String = "Patrol"
var _entity: Node3D = null
var _can_move: bool = false
var _destination_reached: bool = false
var _direction: Vector3 = Vector3.ZERO
var _next_path: Vector3 = Vector3.ZERO
var _speed: float = 120.0

# Diccionario de estados
var _states = {
	"Patrol": Callable(self, "_handle_patrol_state"),
	"Persecution": Callable(self, "_handle_persecution_state"),
	"Attack": Callable(self, "_handle_attack_state")
}

func _ready() -> void:
	# Conexiones de señales
	_agent.navigation_finished.connect(_navigation_finished)
	_timer.wait_time = 4.0
	_timer.autostart = true
	_timer.start()
	_timer.timeout.connect(_on_timer_timeout)

func _process(delta: float) -> void:
	_states[_current_state].call(delta)
	
	if not character.is_on_floor():
		character.velocity.y -= 10.0 * delta
		
	character.move_and_slide()

# Métodos privados de lógica interna
func _change_state(state: String):
	if _states.has(state):
		if _current_state != state:
			print("cambiando estado de :",_current_state," a ",state)
			_current_state = state
	else:
		print("no existe el estad o: ",state)
		
func _handle_patrol_state(delta: float):
	if agent_perception.is_entity_detected():
		_change_state("Persecution")
		return
	elif _can_move:
		_generate_new_route()
		_agent.target_position = _next_path
		_can_move = false
		_destination_reached = false
		
	_direction = (_agent.get_next_path_position() - global_position).normalized()
	if not _destination_reached:
		character.velocity.x = _direction.x * _speed * delta
		character.velocity.z = _direction.z * _speed * delta
		character.rotation.y = _rotate_character(_direction)
	else:
		character.velocity.x = 0
		character.velocity.z = 0

func _handle_persecution_state(delta: float):
	if agent_perception.is_entity_detected():
		_entity = agent_perception.get_entity()
		
		_agent.target_position = _entity.global_position
		_direction = (_agent.get_next_path_position() - global_position).normalized()
		character.velocity.x = _direction.x * _speed * delta
		character.velocity.z = _direction.z * _speed * delta
		character.rotation.y = _rotate_character(_direction)
		
		if agent_perception.is_entity_in_attack_area():
			_change_state("Attack")
	else:
		_change_state("Patrol")

func _handle_attack_state(delta: float):
	if agent_perception.is_entity_detected():
		if not agent_perception.is_entity_in_attack_area():
			_change_state("Persecution")
			hit_box.deactivate_hit()
			
		if agent_perception.is_entity_in_attack_area():
			character.velocity.x = 0
			character.velocity.z = 0
			character.rotation.y = _rotate_character(_direction)
			hit_box.activate_hit()

func _navigation_finished():
	_destination_reached = true

func _generate_new_route():
	_next_path = Vector3(randf_range(0, 15), global_position.y, randf_range(0, 15))

func _rotate_character(dir: Vector3) -> float:
	return atan2(dir.x, dir.z)

func _on_timer_timeout() -> void:
	_can_move = true


# Métodos públicos para acceder a las propiedades
func get_current_state() -> String:
	return _current_state

func is_destination_reached() -> bool:
	return _destination_reached

func get_speed() -> float:
	return _speed

func set_speed(value: float) -> void:
	_speed = value
