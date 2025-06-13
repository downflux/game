class_name DFServerUnitFactory
extends Node

@onready var debug_unit_scene: PackedScene = preload("res://scenes/instances/units/gi.tscn")

var _uid: int = 0


func _generate_unit_id() -> int:
	_uid += 1
	return _uid


func _on_tile_changed(tile: Vector2i, occupied: bool):
	Logger.debug("Unit moved from src to dst: %s --> %s" % [tile, occupied])


func create_unit(faction: DFEnums.Faction) -> DFServerUnitBase:
	var u: DFServerUnitBase = debug_unit_scene.instantiate()
	
	var uid = _generate_unit_id()
	u.name = str(uid)
	u.unit_state.faction = faction
	u.unit_state.unit_id = uid
	
	add_child(u, true)
	
	u.mover.tile_changed.connect(_on_tile_changed)
	
	return u
