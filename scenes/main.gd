extends Node3D

@onready var music: AudioStreamPlayer3D = $Music

func _ready() -> void:
	Audio.play(music)
