extends Node3D

@onready var join_button: Button = $Loby/VBoxContainer/Join
@onready var host_button: Button = $Loby/VBoxContainer/Host
@export var menu: Control
const PLAYER_SCENE = preload("res://scenes/playerScenes/Player.tscn")
const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNECTIONS = 10

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var input_ip: LineEdit = $Loby/VBoxContainer/LineEdit
@onready var send_button: Button = $Loby/VBoxContainer/Send
var players = {}  # Diccionario para almacenar los jugadores
var peer: ENetMultiplayerPeer  # Declara el peer

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	peer = ENetMultiplayerPeer.new()
	multiplayer_spawner.spawn_function = _spawn_player
	send_button.visible = false
	input_ip.visible = false

# Se conecta un nuevo jugador
func _on_player_connected(id):
	if is_multiplayer_authority():  # Solo el servidor autoritativo gestiona esto
		var node_name = "Player" + str(id)
		if has_node(node_name):
			print("El nodo ya existe:", node_name)
			return
		var player = multiplayer_spawner.spawn(node_name)
		players[id] = player
		# Inicializa la posición del jugador
		player.position = Vector3(randf() * 3, 0, randf() * 3)

# Se desconecta un jugador
func _on_player_disconnected(id):
	if players.has(id):
		players[id].queue_free()
		players.erase(id)
		rpc("remove_player", id)


# RPC para eliminar un jugador
@rpc("any_peer")
func remove_player(id):
	if players.has(id):
		players[id].queue_free()
		players.erase(id)

func _on_host_button_up() -> void:
	menu.hide()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error != OK:
		print("Error creando el servidor:", error)
		return
	multiplayer.multiplayer_peer = peer
	_on_player_connected(1)
	print("Servidor iniciado")

func _on_join_button_up() -> void:
	join_button.visible = false
	host_button.visible = false
	input_ip.visible = true
	send_button.visible = true
	
func _on_send_button_ip():
	menu.hide()
	var ip = input_ip.text
	var error = peer.create_client(ip, PORT)
	if error != OK:
		print("Error conectándose al servidor: ", error)
		return
	multiplayer.multiplayer_peer = peer
	print("Cliente conectado")
	
func _spawn_player(id: String) -> Node:
	var player = PLAYER_SCENE.instantiate()
	player.name = id
	return player
