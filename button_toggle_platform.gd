extends Node3D

signal activated(state)

@onready var animation_tree: AnimationTree = $AnimationTree
var current_state = "NotPressed"
@onready var timer: Timer = $Timer
var is_active:bool = false
var is_not_pressed_animation_finished: bool = true
var is_pressed_animation_finished: bool = true
var on_body:bool = false
func _process(delta: float) -> void:
	if (
		on_body and
		current_state == "NotPressed" and 
		(is_not_pressed_animation_finished)
	):
		animation_tree.set("parameters/Transition/transition_request","Pressed")
		current_state = "Pressed"
		is_pressed_animation_finished = false
		is_active = true
	elif (
		not on_body and
		current_state == "Pressed" and 
		(is_pressed_animation_finished)
	):
		animation_tree.set("parameters/Transition/transition_request","NotPressed")
		current_state = "NotPressed"
		is_active = false
		is_not_pressed_animation_finished = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	on_body = true

 # Emite la señal con el nuevo estado
	
func _on_area_3d_body_exited(body: Node3D) -> void:
	on_body = false


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "NotPressed":
		is_not_pressed_animation_finished = true
		emit_signal("activated", is_active) 
		
	elif anim_name == "Pressed":
		is_pressed_animation_finished = true
		emit_signal("activated", is_active) 
		
