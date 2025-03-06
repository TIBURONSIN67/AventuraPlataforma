class_name Healer
extends Node3D

@onready var area_3d: Area3D = $Area3D
var _tween: Tween

@export var add_health: float = 50
var _entity_health: Health = null

func _ready():
	# Crea un Tween persistente y comienza la animación
	_tween = create_tween()
	_tween.set_loops()  # Hace que la animación se repita infinitamente
	animate_item()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Entity"):
		_entity_health = body.get_health_component()
		_entity_health.heal(add_health)
		self.queue_free()

func animate_item():
	_tween.tween_property(area_3d, "position:y", area_3d.position.y + 0.1, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(area_3d, "position:y", area_3d.position.y - 0.1, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
