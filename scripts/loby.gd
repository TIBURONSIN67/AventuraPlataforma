extends Node3D

class_name Loby

@onready var join_button: Button = $Loby/VBoxContainer/Join
@onready var host_button: Button = $Loby/VBoxContainer/Host
@export var menu: Control
const PLAYER_SCENE = preload("res://scenes/playerScenes/Player.tscn")

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var input_ip: LineEdit = $Loby/VBoxContainer/LineEdit
@onready var send_button: Button = $Loby/VBoxContainer/Send

@onready var players_container: Node3D = $Players
var players:Array

func _ready():
	Network.player_connected.connect(_on_player_connected)
	Network.player_disconnected.connect(player_disconect)
	Network.request_damage_signal.connect(request_damage)
	multiplayer_spawner.spawn_function = _spawn_player
	send_button.visible = false
	input_ip.visible = false
	players = players_container.get_children()

func _on_host_button_up() -> void:
	menu.hide()
	Network.create_game()

func _on_join_button_up() -> void:
	join_button.visible = false
	host_button.visible = false
	input_ip.visible = true
	send_button.visible = true

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
	player.position = Vector3(randf() * 3, 15, randf() * 3)
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
		
func request_damage(target_id: int, damage: float):
	if Network.players.has(target_id) and multiplayer.is_server():
		_apply_damage(target_id, damage)
		
func _apply_damage(target_id: int, damage: float):
	if Network.players.has(target_id) and multiplayer.is_server():
		Network.players[target_id]["health"] -= damage
		if Network.players[target_id]["health"] <= 0:
			Network.players[target_id]["health"] = 0
			print("Player", target_id, "has been defeated!")

		# Notifica a todos los clientes sobre el nuevo estado de salud
		rpc("update_health",target_id,Network.players[target_id]["health"])


@rpc("any_peer", "reliable")
func update_health(id:int,new_health: float):
	if Network.players.has(id):
		Network.players[id]["health"] = new_health
		print("Player ", id, " salud actualizada ", new_health)
