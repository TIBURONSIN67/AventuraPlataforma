extends Node3D

@export var activator_node: Node3D  # Nodo activador asignado desde el editor
@export var speed: float = 2.0  # Velocidad de movimiento
@export var distance: float = 5.0  # Distancia máxima de movimiento
@export var direction: Vector3 = Vector3(1, 0, 0)  # Eje del movimiento (X, Y o Z)
@export var initial_direction: int = 1  # Dirección inicial (1 o -1)

var start_pos: Vector3  # Posición inicial de la plataforma
var motion: bool = false  # Estado de movimiento
var target_offset: float = 0.0  # Desplazamiento actual
var moving_direction: int = 1  # Dirección actual (1 o -1)
var new_pos: Vector3  # Posición nueva de la plataforma

func _ready():
	start_pos = global_position  # Guarda la posición inicial
	moving_direction = initial_direction  # Configura la dirección inicial
	activator_node.activated.connect(_on_activator_activated)  # Conecta la señal activadora
	new_pos = start_pos  # Inicializa la nueva posición

func _process(delta):
	if motion:
	# Calcula el desplazamiento en base a la dirección y velocidad
		target_offset += moving_direction * speed * delta	
		# Control de los límites en función del eje seleccionado
		if direction == Vector3(1, 0, 0):  # Movimiento en el eje X
			if abs(new_pos.x - start_pos.x) >= distance or (new_pos.x >= start_pos.x):
				moving_direction *= -1
			new_pos.x += moving_direction * speed * delta

		if direction == Vector3(-1, 0, 0):  # Movimiento en el eje X
			if abs(new_pos.x - start_pos.x) >= distance or (new_pos.x <= start_pos.x):
				moving_direction *= -1
			new_pos.x += moving_direction * speed * delta

		if direction == Vector3(0, 1, 0):  # Movimiento en el eje Y
			if abs(new_pos.y - start_pos.y) >= distance or (new_pos.y >= start_pos.y):
				moving_direction *= -1
			new_pos.y += moving_direction * speed * delta
			
		if direction == Vector3(0, -1, 0):  # Movimiento en el eje Y
			if abs(new_pos.y - start_pos.y) >= distance or (new_pos.y <= start_pos.y):
				moving_direction *= -1
			new_pos.y += moving_direction * speed * delta	
			
		if direction == Vector3(0, 0, 1):  # Movimiento en el eje Z
			if abs(new_pos.z - start_pos.z) >= distance or (new_pos.z >= start_pos.z):
				moving_direction *= -1
			new_pos.z += moving_direction * speed * delta

		if direction == Vector3(0, 0, -1):  # Movimiento en el eje Z
			if abs(new_pos.z - start_pos.z) >= distance or (new_pos.z <= start_pos.z):
				moving_direction *= -1
			new_pos.z += moving_direction * speed * delta

		global_position = new_pos

func _on_activator_activated(state: bool):
	motion = state  # Inicia o detiene el movimiento
