extends Node3D

var player_scene1:PackedScene = preload("res://Scenes/playerScenes/player_1.tscn")
var player_scene2:PackedScene = preload("res://Scenes/playerScenes/player_2.tscn")
var player_scene3:PackedScene = preload("res://scenes/playerScenes/player_3.tscn")
const _1_PLAYERS_VIEW = preload("res://scenes/viewScene/1PlayerView.tscn")
const _2_PLAYERS_VIEW = preload("res://scenes/viewScene/2PlayersView.tscn")
const _3_PLAYERS_VIEW = preload("res://scenes/viewScene/3PlayersView.tscn")
var _1_players_view
var _2_players_view
var _3_players_view
@onready var player_pos1: Marker3D = $PlayerPos1
@onready var player_pos2: Marker3D = $PlayerPos2
@onready var player_pos3: Marker3D = $PlayerPos3
@onready var sub_viewport1: SubViewportContainer 
@onready var sub_viewport2: SubViewportContainer 
@onready var sub_viewport3: SubViewportContainer 
@onready var menu: Control = $Menu

var player1:Node3D
var player2:Node3D
var player3:Node3D
var screen1
var screen2
var screen3
func _ready():
	if Global.selected_players == 1:
		_1_players_view = _1_PLAYERS_VIEW.instantiate()
		add_child(_1_players_view)
		sub_viewport1 = _1_players_view.get_node("Screen1")
		screen1 = sub_viewport1.get_node("SubViewport")
		spawn_player1(player_pos1, 1)
		
	elif Global.selected_players == 2:
		_2_players_view = _2_PLAYERS_VIEW.instantiate()
		add_child(_2_players_view)
		sub_viewport1 = _2_players_view.get_node("Screen1")
		sub_viewport2 = _2_players_view.get_node("Screen2")
		screen1 = sub_viewport1.get_node("SubViewport")
		screen2 = sub_viewport2.get_node("SubViewport")
		spawn_player1(player_pos1, 1)
		spawn_player2(player_pos2, 1)
			
	elif Global.selected_players == 3:
		_3_players_view = _3_PLAYERS_VIEW.instantiate()
		add_child(_3_players_view)
		sub_viewport1 = _3_players_view.get_node("Screen1")
		sub_viewport2 = _3_players_view.get_node("Screen2")
		sub_viewport3 = _3_players_view.get_node("Screen3")
		screen1 = sub_viewport1.get_node("SubViewport")
		screen2 = sub_viewport2.get_node("SubViewport")
		screen3 = sub_viewport3.get_node("SubViewport")
		spawn_player1(player_pos1, 1)
		spawn_player2(player_pos2, 2)
		spawn_player3(player_pos3, 3)
func spawn_player1(spawn_point, player_id):
	player1 = player_scene1.instantiate()
	player1.name = "Player_%d" % player_id
	player1.position = spawn_point.global_position
	screen1.add_child(player1)
	
func spawn_player2(spawn_point, player_id):
	player2 = player_scene2.instantiate()
	player2.name = "Player_%d" % player_id
	player2.position = spawn_point.global_position
	screen2.add_child(player2)
	
func spawn_player3(spawn_point, player_id):
	player3 = player_scene3.instantiate()
	player3.name = "Player_%d" % player_id
	player3.position = spawn_point.global_position
	screen3.add_child(player3)
