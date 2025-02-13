extends Node3D

var _current_point:Vector3

func set_current_point(pos:Vector3)-> void:
	_current_point = pos

func get_current_point()-> Vector3:
	return _current_point
