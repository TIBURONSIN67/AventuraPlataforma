extends Control

func _ready() -> void:
	if is_multiplayer_authority():
		visible = true
