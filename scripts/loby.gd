extends Node3D

class_name Loby

@onready var join_button: Button = $Loby/BoxContainer/VBoxContainer/Join
@onready var host_button: Button = $Loby/BoxContainer/VBoxContainer/Host
@export var menu: Control
const PLAYER_SCENE = preload("res://scenes/playerScenes/Player.tscn")

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var input_ip: LineEdit = $Loby/BoxContainer/VBoxContainer/LineEdit
@onready var send_button: Button = $Loby/BoxContainer/VBoxContainer/Send
@onready var local_address: Label = $Loby/BoxContainer/VBoxContainer/LocalAddress
@onready var back_button: Button = $Loby/VBoxContainer/Back
@onready var players_container: Node3D = $Players
var players:Array

func _ready():
	back_button.visible = false
	Network.player_connected.connect(_on_player_connected)
	Network.player_disconnected.connect(player_disconect)
	multiplayer_spawner.spawn_function = _spawn_player
	send_button.visible = false
	input_ip.visible = false
	players = players_container.get_children()
	local_address.text = get_local_ip()

func _on_host_button_up() -> void:
	menu.hide()
	Network.create_game()

func _on_join_button_up() -> void:
	back_button.visible = true
	join_button.visible = false
	host_button.visible = false
	input_ip.visible = true
	send_button.visible = true
	local_address.visible = false

func _on_send_button_ip():
	menu.hide()
	var ip = input_ip.text
	Network.join_game(ip)

# Se conecta un nuevo jugador
func _on_player_connected(id,player_info):
	if multiplayer.is_server():  # Solo el servidor crea jugadores
		var node_name = "Player" + str(id)
		var player = multiplayer_spawner.spawn(node_name)
		Network.add_player(id,player)
		
# Spawnea un jugador
func _spawn_player(id: String) -> Node:
	var player = PLAYER_SCENE.instantiate()
	player.name = id
	player.position = Vector3(randf() * 3, 30, randf() * 3)
	return player

func player_disconect(player):
	print("el usuario : ",player.node.name," se desconecto del servidor")
	var node_path = player["node"].get_path()
	var player_node = get_node(node_path)
	if player:
		print("Removiendo nodo:", player)
		player_node.queue_free()
	else:
		print("Nodo no encontrado:", node_path)
		
func get_local_ip()->String:
	var local_addresses = IP.get_local_addresses()
	var address = ""
	for i in local_addresses:
		if i.length() <= 11 and (i.find("192.168") != -1):
			address = i
			return address
	
	return address

func _on_back_button_up() -> void:
	join_button.visible = true
	host_button.visible = true
	local_address.visible = true
	send_button.visible = false
	input_ip.visible = false
	back_button.visible = false
