class_name  EnemyClassA extends CharacterBody3D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var particles_trail: CPUParticles3D = $CPUParticles3D

@export var health:Health = null

var animation_states = {
	"Idle": "Idle",
	"Run": "Run",
	"MeleAttack": "MeleAttack"
}
var current_animation_state: String
@export var agent_controller:AgentController = null
var current_agent_state:String
@onready var audio: AudioStreamPlayer3D = $Audio

func _ready() -> void:
	if agent_controller != null:
		current_agent_state = agent_controller.get_current_state()
	else:
		print("ningun agente asignado")
	if health != null:
		health.is_dead.connect(_is_dead)
	else:
		print("ningun agente asignado")
func _process(delta: float) -> void:
	handle_effects()
	if current_agent_state == "Patrol":
		if velocity.length() > 0:
			change_anim_move_state("Run")
		else:
			change_anim_move_state("Idle")
	if current_agent_state == "Persecution":
		change_anim_move_state("Run")
			
	elif current_agent_state == "Attack":
		play_anim_melee_attack()
		change_anim_move_state("Idle")
	
# Manejo de efectos (partículas y sonido)
func handle_effects():
	if is_on_floor():
		if velocity.length() > 0.5:
			particles_trail.emitting = true
			audio.stream_paused = false
		else:
			particles_trail.emitting = false
			audio.stream_paused = true
			

func _change_state(state:String):
	current_agent_state = state
	print("Estado recibido ", state)

func change_anim_move_state(new_state: String) -> void:
	if current_animation_state != new_state:  # Solo cambia si es diferente
		if animation_states.has(new_state):
			var target_index = animation_states[new_state]
			if target_index != animation_tree.get("parameters/Transition/current_state"):
				current_animation_state = new_state
				animation_tree.set("parameters/Transition/transition_request", target_index)
		else:
			print("No se encontró el estado:", new_state, "en el diccionario")

# Reproducción de animación de ataque cuerpo a cuerpo
func play_anim_melee_attack():
	if not animation_tree.get("parameters/MeleAttack/active"):
		animation_tree.set("parameters/MeleAttack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func _is_dead():
	self.queue_free()
