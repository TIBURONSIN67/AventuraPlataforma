extends Control

@export var health: Health = null

@onready var button_respawn: Button = $BoxContainer/ButtonRespawn
@onready var game_over_message: Label = $BoxContainer2/GameOverMessage
@onready var main_menu_button: Button = $BoxContainer/MainMenuButton
@onready var lifes: Label = $BoxContainer2/Lifes

const MENU = preload("res://scenes/menu.tscn")

func _ready() -> void:
	self.visible = false
	main_menu_button.visible = false
	game_over_message.visible = false
	button_respawn.button_up.connect(_respawn)
	button_respawn.button_down.connect(_respawn_down)
	main_menu_button.button_up.connect(_main_menu)
	if health != null:
		health.is_dead.connect(_on_is_dead)
		health.updated_health.connect(_on_update_health)
	else:
		print("Health no asignado: ", name)

func _respawn():
	Input.action_press("Respawn")
func _respawn_down():
	Input.action_release("Respawn")
	
	
func _on_is_dead():
	self.visible = true  # Mostrar UI cuando muere
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if PlayerAttributes.life >= 1:
		lifes.visible = true
		var text:String = ("Intentos : " + str(PlayerAttributes.life))
		lifes.text = text
	elif PlayerAttributes.life <= 0:
		game_over_message.visible = true
		lifes.visible = false
		button_respawn.visible = false
		main_menu_button.visible = true
		

func _main_menu():
	PlayerAttributes.restart()
	get_tree().change_scene_to_packed(MENU)

func _on_update_health(current_health: float, min: float, max: float):
	if current_health > min:  
		self.visible = false  # Ocultar UI si revive
