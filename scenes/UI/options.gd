extends Control

@onready var master_slider: HSlider = $BoxContainer/VBoxContainer/MasterSlider
@onready var music_slider: HSlider = $BoxContainer/VBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $BoxContainer/VBoxContainer/SfxSlider

# Diccionario con los nombres de los buses
var buses = {
	"Master": AudioServer.get_bus_index("Master"),
	"Music": AudioServer.get_bus_index("Music"),
	"Sfx": AudioServer.get_bus_index("Sfx")
}

func _ready():
	for bus in buses.keys():
		if buses[bus] != -1:  # Verifica si el bus existe
			var slider = get_slider(bus)
			slider.value = db_to_linear(AudioServer.get_bus_volume_db(buses[bus]))

	# Conectar señales
	master_slider.connect("value_changed", _on_slider_value_changed.bind("Master"))
	music_slider.connect("value_changed", _on_slider_value_changed.bind("Music"))
	sfx_slider.connect("value_changed", _on_slider_value_changed.bind("Sfx"))

# Función para cambiar el volumen, válida para cualquier bus
func _on_slider_value_changed(value: float, bus_name: String):
	if buses[bus_name] != -1:
		AudioServer.set_bus_volume_db(buses[bus_name], linear_to_db(value))

# Obtiene el slider correcto según el nombre del bus
func get_slider(bus_name: String) -> HSlider:
	match bus_name:
		"Master": return master_slider
		"Music": return music_slider
		"Sfx": return sfx_slider
	return null
