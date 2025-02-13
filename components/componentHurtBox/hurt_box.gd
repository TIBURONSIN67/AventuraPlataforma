class_name HurtBox extends Node3D

@export var health:Health = null
@export var hurt_audio:AudioStreamPlayer3D = null
@export var character:Node3D = null
var is_entity_dead:bool = false

func _ready() -> void:
	health.is_dead.connect(_is_dead)
	health.updated_health.connect(_updated_health)
	
func _process(delta: float) -> void:
	if character != null:
		character.scale = lerp(character.scale, Vector3(1,1,1), delta * 6)
		
func _updated_health(current_health:float, min_health:float, max_health:float):
	if current_health > min_health:
		is_entity_dead = false
	
func take_damage(damage:float):
	if health != null and not is_entity_dead:
		health.take_damage(damage)
		if hurt_audio != null:
			Audio.play(hurt_audio)
		else:
			print("agregue un stream player :",get_parent().name)
		
		if character != null:
			character.scale = Vector3(0.95, 0.9, 0.95)

func _is_dead():
	is_entity_dead = true
