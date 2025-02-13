extends Node

var platform_name:String

func _ready() -> void:
	platform_name = OS.get_name()
	print(platform_name)
	
	
func is_android()->bool:
	return platform_name == "Android"
	
func is_windows()->bool:
	return platform_name == "Windows"
