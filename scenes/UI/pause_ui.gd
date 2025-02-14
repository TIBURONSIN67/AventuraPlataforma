extends Control

@onready var button_resume: Button = $BoxContainer/VBoxContainer/ButtonResume
@onready var button_exit: Button = $BoxContainer/VBoxContainer/ButtonExit
@onready var button_options: Button = $BoxContainer/VBoxContainer/ButtonOptions

@onready var options: Options = $Options
@onready var back_button: Button = $BoxContainer2/VBoxContainer/BackButton

var is_paused: bool = false

@export var health: Health = null
var is_dead: bool = false

func _ready() -> void:
	button_resume.button_up.connect(_on_button_resume_pressed)
	button_exit.button_up.connect(_on_button_exit_pressed)
	button_options.button_up.connect(_on_button_options_pressed)
	back_button.button_up.connect(_on_back_button_pressed)  # Conectar botón "Back"
	
	options.visible = false
	back_button.visible = false  # Ocultar el botón "Back" al inicio
	self.visible = false

	if health != null:
		health.is_dead.connect(_on_is_dead)
		health.updated_health.connect(_on_update_health)
	else:
		print("Health no asignado: ", name)
		
func _on_is_dead():
	is_dead = true

func _on_update_health(current_health: float, min: float, max: float):
	if current_health > min:  
		is_dead = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause") and not is_dead:
		if not is_paused:
			get_tree().paused = true
			self.visible = true 
			is_paused = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

		elif is_paused:
			is_paused = false
			get_tree().paused = false
			self.visible = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_button_resume_pressed() -> void:
	get_tree().paused = false  
	self.visible = false  
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_button_exit_pressed() -> void:
	get_tree().quit() 

func _on_button_options_pressed() -> void:
	options.visible = true  
	back_button.visible = true  # Mostrar el botón "Back"

func _on_back_button_pressed() -> void:
	options.visible = false  
	back_button.visible = false  # Ocultar el botón "Back" al volver
