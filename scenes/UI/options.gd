class_name Options extends Control

@onready var master_slider: HSlider = $BoxContainer/VBoxContainer/MasterSlider
@onready var music_slider: HSlider = $BoxContainer/VBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $BoxContainer/VBoxContainer/SfxSlider

# Almacena los índices de los buses de audio
var bus_master: int = AudioServer.get_bus_index("Master")
var bus_music: int = AudioServer.get_bus_index("Music")
var bus_sfx: int = AudioServer.get_bus_index("Sfx")

func _ready() -> void:
	# Conectar cada slider a su función respectiva
	master_slider.connect("value_changed", _on_master_slider_changed)
	music_slider.connect("value_changed", _on_music_slider_changed)
	sfx_slider.connect("value_changed", _on_sfx_slider_changed)

	# Imprimir los índices de los buses para verificar si existen
	print("Master Bus Index: ", bus_master)
	print("Music Bus Index: ", bus_music)
	print("SFX Bus Index: ", bus_sfx)
	# Configurar valores iniciales de los sliders
	set_sliders()

func set_sliders():
	if bus_master != -1:
		master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_master))
	if bus_music != -1:
		music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_music))
	if bus_sfx != -1:
		sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_sfx))

# Funciones separadas para cada slider
func _on_master_slider_changed(value: float):
	if bus_master != -1:
		AudioServer.set_bus_volume_db(bus_master, linear_to_db(value))

func _on_music_slider_changed(value: float):
	if bus_music != -1:
		AudioServer.set_bus_volume_db(bus_music, linear_to_db(value))

func _on_sfx_slider_changed(value: float):
	if bus_sfx != -1:
		AudioServer.set_bus_volume_db(bus_sfx, linear_to_db(value))
