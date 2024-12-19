extends Control

const MAIN = preload("res://scenes/main.tscn")

func _ready():
	pass

func _process(_delta: float) -> void:
	pass
	
func _on_button_1_player_pressed():
	Global.selected_players = 1  # Establecer el valor en el singleton
	get_tree().change_scene_to_packed(MAIN)

func _on_button_2_players_pressed():
	Global.selected_players = 2  # Establecer el valor en el singleton
	get_tree().change_scene_to_packed(MAIN)

func _on_button_3_players_pressed():
	Global.selected_players = 3  # Establecer el valor en el singleton
	get_tree().change_scene_to_packed(MAIN)

func _on_button_4_players_pressed():
	Global.selected_players = 4  # Establecer el valor en el singleton
	get_tree().change_scene_to_packed(MAIN)
