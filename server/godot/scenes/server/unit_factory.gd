class_name DFServerUnitFactory
extends Node

@onready var debug_unit_scene: PackedScene = preload("res://scenes/instances/units/gi/gi.tscn")
@onready var debug_occupied: TileMapLayer = $DebugOccupied
@onready var debug_next: TileMapLayer = $DebugNext

var _uid: int = 0


signal bus_curr_tile_changed(uid: int, src: Vector2i, dst: Vector2i)
signal bus_next_tile_changed(uid: int, src: Vector2i, dst: Vector2i)


func _generate_unit_id() -> int:
	_uid += 1
	return _uid


func _on_curr_tile_changed(src: Vector2i, dst: Vector2i):
	if src != Vector2i.MAX:
		debug_occupied.erase_cell(src)
	if dst != Vector2i.MAX:
		debug_occupied.set_cell(dst, 0, Vector2i(0, 0))


func _on_next_tile_changed(src: Vector2i, dst: Vector2i):
	if src != Vector2i.MAX:
		debug_next.erase_cell(src)
	if dst != Vector2i.MAX:
		debug_next.set_cell(dst, 0, Vector2i(0, 0))


func create_unit(faction: DFEnums.Faction) -> DFServerUnitBase:
	var u: DFServerUnitBase = debug_unit_scene.instantiate()
	
	var uid = _generate_unit_id()
	u.name = str(uid)
	u.unit_state.faction = faction
	u.unit_state.unit_id = uid
	
	add_child(u, true)
	
	u.mover.curr_tile_changed.connect(_on_curr_tile_changed)
	u.mover.next_tile_changed.connect(_on_next_tile_changed)
	u.mover.curr_tile_changed.connect(
		func(src: Vector2i, dst: Vector2i): bus_curr_tile_changed.emit(uid, src, dst)
	)
	u.mover.next_tile_changed.connect(
		func(src: Vector2i, dst: Vector2i): bus_next_tile_changed.emit(uid, src, dst)
	)
	
	return u
