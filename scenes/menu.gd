extends Control

@onready var play_button: Button = $BoxContainer/VBoxContainer/PlayButton
@onready var exit_button: Button = $BoxContainer/VBoxContainer/ExitButton
@onready var options_button: Button = $BoxContainer/VBoxContainer/OptionsButton  # Botón de opciones

@onready var main_scene: PackedScene = load("res://scenes/main.tscn")

@onready var music: AudioStreamPlayer3D = $Music
const BUS = preload("res://Bus.tres")

@onready var options: Control = $Options
@onready var back_button: Button = $BoxContainer2/VBoxContainer/BackButton

func _ready():
	if BUS:
		AudioServer.set_bus_layout(BUS)  # Aplica el layout de buses al AudioServer

	exit_button.button_up.connect(_on_button_exit_pressed)
	play_button.button_up.connect(play_game)
	options_button.button_up.connect(_on_button_options_pressed)  # Conectar el botón de opciones
	back_button.button_up.connect(_on_back_button_pressed)  # Conectar el botón "Back"

	Audio.play(music)
	options.visible = false
	back_button.visible = false  # Ocultar botón "Back" al inicio

func play_game():
	get_tree().change_scene_to_packed(main_scene)

func _on_button_exit_pressed() -> void:
	get_tree().quit()

func _on_button_options_pressed() -> void:
	options.visible = true  
	back_button.visible = true  # Mostrar el botón "Back" solo dentro de opciones

func _on_back_button_pressed() -> void:
	options.visible = false  
	back_button.visible = false  # Ocultar botón "Back" al regresar al menú principal
