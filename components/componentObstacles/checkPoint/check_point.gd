extends Node3D

@onready var area_3d: Area3D = $Area3D

func _ready():
	area_3d.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	if body.is_in_group("Player"):
		if HandleCheckPoint.has_method("set_current_point"):
			HandleCheckPoint.set_current_point(body.global_position)
		else:
			print("Error: HandleCheckPoint no tiene el método set_current_point()")
