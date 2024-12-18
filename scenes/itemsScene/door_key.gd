extends Area3D

var time := 0.0
var grabbed := false

# Collecting coins

func _on_body_entered(body):
	if body.has_method("collect_door_key") and !grabbed:
		body.collect_door_key()
		Audio.play("res://sounds/coin.ogg") # Play sound
		queue_free() # Make invisible
		grabbed = true

# Rotating, animating up and down

func _process(delta):
	rotate_y(2 * delta) # Rotation
	position.y += (cos(time * 5) * 1) * delta 
	
	time += delta
