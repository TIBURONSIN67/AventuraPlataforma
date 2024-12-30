extends Area3D

@export var damage:float = 10

func _on_body_entered(body: Node3D) -> void:
	if not body.name == get_parent().name:
		print("llamando a requet damage")
		Network.request_damage(body.name.to_int(), damage)  # Llama directamente si es el servidor
		return
