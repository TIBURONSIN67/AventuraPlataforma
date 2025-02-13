extends Node3D

@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $Piston/AnimationPlayer

@export var open_time: float = 1.0  # Tiempo de apertura (Push)
@export var close_time: float = 1.0  # Tiempo de cierre (Back)
@export var push_force: float = 10.0  # Fuerza del pistón

var playing_push: bool = false  # Controla si está en "Push" o "Back"
var push_direction: Vector3  # Dirección calculada una sola vez

func _ready():
	# Obtener la dirección local en relación al padre una vez al inicio
	animation_player.play("Back")  # Inicia cerrado
	timer.wait_time = close_time  
	timer.timeout.connect(_toggle_animation)  
	timer.start()

func _toggle_animation():
	if playing_push:
		animation_player.play("Back")
		timer.wait_time = close_time  
	else:
		animation_player.play("Push")
		timer.wait_time = open_time  

	playing_push = !playing_push  
	timer.start()  
