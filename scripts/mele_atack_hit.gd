extends Area3D

@export var damage:float = 30

func _on_body_entered(body: Node3D) -> void:
	if not body.name == get_parent().name:
		if multiplayer.is_server():
			Network.request_damage(body.name.to_int(), damage)  # Llama directamente si es el servidor
		else:
			Network.request_damage.rpc_id(1, body.name.to_int(), damage)  # 1 es el ID del servidor
