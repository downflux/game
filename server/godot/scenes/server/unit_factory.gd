class_name DFServerUnitFactory
extends Node

@onready var debug_unit_scene: PackedScene = preload("res://scenes/instances/units/gi.tscn")

var _uid: int = 0


func _generate_unit_id() -> int:
	var uid = _uid + 1
	_uid += 1
	return uid


func create_unit() -> DFServerUnitBase:
	var u = debug_unit_scene.instantiate()
	
	u.unit_id = _generate_unit_id()
	u.name = str(u.unit_id)
	
	add_child(u, true)
	return u
