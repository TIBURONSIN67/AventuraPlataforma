extends Control

@onready var canvas_layer: CanvasLayer = $Pause

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = not get_tree().paused
		canvas_layer.visible = not canvas_layer.visible


#para cuando se presiona play
func _on_resume_button_up() -> void:
	canvas_layer.visible = false
	get_tree().paused = false

#Cuando se presion Quit
func _on_quit_button_up() -> void:
	get_tree().quit()
