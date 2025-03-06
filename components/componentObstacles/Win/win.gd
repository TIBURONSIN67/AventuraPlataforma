extends Node3D

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var win: Control = $CanvasLayer/Win
@onready var fondo: ColorRect = $CanvasLayer/Win/Fondo
@onready var backgrund_button: NinePatchRect = $CanvasLayer/Win/BackgrundButton
@onready var box_container: BoxContainer = $CanvasLayer/Win/BoxContainer
@onready var v_box_container: VBoxContainer = $CanvasLayer/Win/BoxContainer/VBoxContainer
@onready var main_menu_button: Button = $CanvasLayer/Win/BoxContainer/MainMenuButton
@onready var box_container_2: BoxContainer = $CanvasLayer/Win/BoxContainer2
@onready var win_label: Label = $CanvasLayer/Win/BoxContainer2/WinLabel
@onready var win_area: Area3D = $WinArea
@onready var collision_shape_3d: CollisionShape3D = $WinArea/CollisionShape3D

const MENU = preload("res://scenes/menu.tscn")

func _ready():
	win.visible = false
	win.modulate.a = 0  # Hace que la pantalla inicie invisible
	win_area.body_entered.connect(_on_win_area_body_entered)
	main_menu_button.button_up.connect(_main_menu)

func _on_win_area_body_entered(body):
	if body.is_in_group("Player"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		show_win_screen()

func show_win_screen():
	win.visible = true
	var tween = get_tree().create_tween()  # Crear el Tween dentro de la función
	tween.tween_property(win, "modulate:a", 1, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _main_menu():
	PlayerStats.ResetAllAttributes()
	get_tree().change_scene_to_packed(MENU)
