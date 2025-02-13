class_name BulletA extends RigidBody3D

@export var bullet_speed: float = 25.0  
@export var life_time: float = 5.0  
@onready var timer: Timer = $Timer

@onready var component_hit_box: HitBox = $ComponentHitBox

func _ready():
	timer.wait_time = life_time
	timer.one_shot = true  
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _shoot(direccion: Vector3, pos:Vector3):
	global_position = pos
	direccion = direccion.normalized()
	linear_velocity = direccion * bullet_speed

func _on_timer_timeout():
	queue_free()

func set_speed(speed:float):
	bullet_speed = speed

func set_damage(damage:float):
	component_hit_box.set_damage(damage)
