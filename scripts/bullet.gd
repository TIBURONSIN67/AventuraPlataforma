extends RigidBody3D
@onready var timer: Timer = $Timer

func _ready():
	timer.one_shot = true
	timer.wait_time = 10
	timer.start()
	sleeping = false  

func _on_timer_timeout() -> void:
	queue_free()
