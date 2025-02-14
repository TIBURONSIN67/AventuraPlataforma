extends Control

@onready var play_button: Button = $BoxContainer/VBoxContainer/PlayButton
@onready var exit_button: Button = $BoxContainer/VBoxContainer/ExitButton
@onready var main_scene: PackedScene = load("res://scenes/main.tscn")

@onready var music: AudioStreamPlayer2D = $Audio


func _ready():
	exit_button.button_up.connect(_on_button_exit_pressed)
	play_button.button_up.connect(play_game)
	music.play()
	
func play_game():
	get_tree().change_scene_to_packed(main_scene)

func _on_button_exit_pressed() -> void:
	get_tree().quit()
