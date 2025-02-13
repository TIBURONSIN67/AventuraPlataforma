class_name HitBox extends Node3D

@onready var collision: CollisionShape3D = $Area3D/CollisionShape3D
@onready var hit_area: Area3D = $Area3D
@onready var timer: Timer = $Timer
@export var is_shoot:bool = false
@export var damage: float = 30.0
@export var wait_time: float = 0.5

@onready var particle: CPUParticles3D = $Particle

var hurt_box: HurtBox = null
var is_active: bool = false  # Indica si el HitBox está activo
var is_timer_running: bool = false  # Indica si el temporizador está en marcha

func _ready() -> void:
	hit_area.area_entered.connect(_on_area_entered)
	timer.timeout.connect(_on_timer_timeout)
	_reset_hitbox() 
	if is_shoot:
		activate_hit()

# Activar el HitBox y comenzar el temporizador
func activate_hit() -> void:
	if not is_timer_running:
		is_active = true
		is_timer_running = true
		collision.disabled = false  # Activar la colisión
		if not is_shoot:
			timer.start(wait_time)


# Desactivar el HitBox manualmente
func deactivate_hit() -> void:
	_reset_hitbox()
	timer.stop()
	is_timer_running = false

# Resetear el estado del HitBox
func _reset_hitbox() -> void:
	is_active = false
	collision.disabled = true
	hurt_box = null  # Limpiar referencias de HurtBox

# Evento llamado al terminar el temporizador
func _on_timer_timeout() -> void:
	is_timer_running = false
	if hurt_box:
		hurt_box.take_damage(damage)
		particle.global_position = hurt_box.global_position
		particle.emitting = true
		print("Daño aplicado: ",damage)
	_reset_hitbox()

# Detectar cuando un área entra en el HitBox
func _on_area_entered(area: Area3D) -> void:
	# Verificar si el área es un HurtBox válido
	if area.get_parent() is HurtBox:
		hurt_box = area.get_parent()
		if is_shoot:
			hurt_box.take_damage(damage)
			particle.global_position = hurt_box.global_position
			particle.emitting = true

func set_damage(d:float):
	damage = d
