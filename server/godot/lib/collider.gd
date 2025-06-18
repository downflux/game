class_name DFUnitCollider
extends Node

@export var units: DFServerUnits
@export var debug_state: DFServerState


var _curr_tiles: Dictionary[Vector2i, int] = {}
var _next_tiles: Dictionary[int, Vector2i] = {}


func on_bus_curr_tile_changed(uid: int, src: Vector2i, dst: Vector2i):
	if src in _curr_tiles:
		_curr_tiles.erase(src)
	if dst != Vector2i.MAX:
		_curr_tiles[dst] = uid


func on_bus_next_tile_changed(uid: int, src: Vector2i, dst: Vector2i):
	if uid in _next_tiles:
		_next_tiles.erase(uid)
	if dst != Vector2i.MAX:
		_next_tiles[uid] = dst


func _physics_process(_delta):
	for u: DFServerUnitBase in units.get_children():
		if (
			u.unit_state.unit_id in _next_tiles
		) and (
			_next_tiles[u.unit_state.unit_id] in _curr_tiles
		):
			u.mover.delay(debug_state.timestamp_msec)
