extends Node

var playing = []  # Lista de nodos actualmente reproduciendo sonidos.

func _on_stream_finished(player: AudioStreamPlayer3D):
	# Mueve el nodo de la lista de reproducción una vez que termina
	if player in playing:
		playing.erase(player)

# Método para reproducir sonidos, recibe un AudioStreamPlayer3D configurado
func play(audio_stream_player: AudioStreamPlayer3D):
	if not audio_stream_player:
		print("Error: Se recibió un AudioStreamPlayer3D nulo.")
		return

	if audio_stream_player.is_playing():
		print("El nodo ya está reproduciendo. Deteniéndolo para reproducir de nuevo.")
		audio_stream_player.stop()

	# Configurar propiedades del nodo si es necesario
	audio_stream_player.pitch_scale = randf_range(1, 1.3)  # Variación de pitch
	# Reproducir el sonido
	audio_stream_player.play()

	# Mover el nodo a la lista de reproducción
	playing.append(audio_stream_player)

	# Conectar el evento `finished` si no está conectado ya
	if not audio_stream_player.finished.is_connected(_on_stream_finished):
		audio_stream_player.finished.connect(_on_stream_finished.bind(audio_stream_player))

func _process(_delta):
	# Opcional: Aquí puedes agregar lógica para gestionar o depurar nodos activos.
	pass
