extends Control

@onready var h_box_container: HBoxContainer = $HBoxContainer
@export var virtual_joystick: VirtualJoystick = null
@onready var h_box_container_2: HBoxContainer = $HBoxContainer2
@onready var jump: TouchScreenButton = $HBoxContainer2/Jump
@onready var attack_mele: TouchScreenButton = $HBoxContainer2/AttackMele
@onready var health_progress_bar: TextureProgressBar = $HealthProgressBar

@onready var button_pause: Button = $ButtonPause

@export var health:Health = null
@export var entity:CharacterBody3D = null

var entity_dead: bool = false
var respawn_health: float = 100.0


func _ready() -> void:
	button_pause.button_down.connect(_button_pause_down)
	button_pause.button_up.connect(_button_pause_up)
	
	if Platform.is_windows():
			_set_ui("desktop")
	elif Platform.is_android():
		_set_ui("mobile")
		
	health.is_dead.connect(_entity_dead)
	HandleCheckPoint.set_current_point(entity.global_position)
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Respawn"):
		if entity_dead and PlayerAttributes.life > 0:
			PlayerAttributes.life -= 1
			entity_dead = false
			health.set_current_health(respawn_health)
			entity.global_position = HandleCheckPoint.get_current_point()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
		

func _entity_dead():
	entity_dead = true
	
func _set_ui(type: String) -> void:
	match type:
		"mobile":
			_configure_mobile_ui()
		"desktop":
			_configure_desktop_ui()

func _configure_mobile_ui() -> void:
	virtual_joystick.visible = true
	jump.visible = true
	attack_mele.visible = true
	h_box_container.visible = true
	h_box_container_2.visible = true
	health_progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _configure_desktop_ui() -> void:
	virtual_joystick.visible = false
	jump.visible = false
	attack_mele.visible = false
	h_box_container.visible = false
	h_box_container_2.visible = false
	health_progress_bar.size_flags_horizontal = Control.SIZE_FILL

func _button_pause_up():
	Input.action_release("Pause")
	
func _button_pause_down():
	Input.action_press("Pause")
