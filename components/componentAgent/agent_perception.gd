class_name AgentPerception
extends Node

# Áreas y raycast configurados como privados
@onready var _vision_area: Area3D = $VisionArea
@onready var _attack_area: Area3D = $AttackArea
@onready var _raycast: RayCast3D = $Raycast
@onready var _raycast_origin: Marker3D = $RaycastOrigin

# Atributos privados
var _entity_in_the_attack_area: bool = false
var _someone_inside: bool = false
var _entity: Node3D = null
var _target_detected: bool = false

func _ready() -> void:
	# Conexiones de señales
	_vision_area.body_entered.connect(_see_a_body)
	_vision_area.body_exited.connect(_not_see_a_body)
	_attack_area.body_entered.connect(_in_the_attack_area)
	_attack_area.body_exited.connect(_out_the_attack_area)

# Métodos privados para manejar eventos de las áreas
func _see_a_body(body: Node3D) -> void:
	if body.is_in_group("Entity") and body != self.get_parent():
		_entity = body

func _not_see_a_body(body: Node3D) -> void:
	if body == _entity:
		_entity = null
		_raycast.enabled = false

func _in_the_attack_area(body: Node3D) -> void:
	if body == _entity:
		_entity_in_the_attack_area = true

func _out_the_attack_area(body: Node3D) -> void:
	if body == _entity:
		_entity_in_the_attack_area = false

func _throw_raycast(target:Vector3)-> bool:
	_raycast.enabled = true
	_raycast.global_position = _raycast_origin.global_position
	_raycast.target_position = target - _raycast.global_position
	var collider:Node3D = _raycast.get_collider()
	if collider != null and collider.is_in_group("Entity"):
		return true
	else:
		return false  

# Métodos públicos para acceder a las propiedades
func is_entity_in_attack_area() -> bool:
	return _entity_in_the_attack_area

func is_entity_detected() -> bool:
	if _entity != null:
		var _target = _entity.global_position
		return _throw_raycast(_target)
	else:
		return false

func get_entity() -> Node3D:
	return _entity
