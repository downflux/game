class_name DFUnitCollider
extends Node

@export var units: DFServerUnits
@export var map: DFServerMap
@export var state: DFServerState

var _curr_tiles: Dictionary[Vector2i, int] = {}
var _curr_tiles_reverse_lookup: Dictionary[int, Vector2i] = {}
var _next_tiles: Dictionary[int, Vector2i] = {}


func on_bus_curr_tile_changed(uid: int, src: Vector2i, dst: Vector2i):
	if src in _curr_tiles:
		map.set_solid(
			src,
			false,
			units.get_unit(uid).unit_state.map_layer.get_value(
				T.get_timestamp_msec(),
			),
		)
		_curr_tiles_reverse_lookup.erase(_curr_tiles[src])
		_curr_tiles.erase(src)
	if dst != Vector2i.MAX:
		_curr_tiles[dst] = uid
		_curr_tiles_reverse_lookup[uid] = dst
		map.set_solid(
			dst,
			true,
			units.get_unit(uid).unit_state.map_layer.get_value(
				T.get_timestamp_msec(),
			),
		)


func on_bus_next_tile_changed(uid: int, _src: Vector2i, dst: Vector2i):
	if uid in _next_tiles:
		_next_tiles.erase(uid)
	if dst != Vector2i.MAX:
		_next_tiles[uid] = dst


func _issue_move(uid: int, dst: Vector2i):
	var u: DFServerUnitBase = units.get_unit(uid)
	if u != null:
		state.set_vector_path(uid, state.get_vector_path(uid, dst))


func _physics_process(_delta):
	for u: DFServerUnitBase in units.get_children():
		var t: Vector2i = _next_tiles.get(
			u.unit_state.unit_id,
			Vector2i.MAX,
		)
		if (
			t in _curr_tiles
		) and (
			_curr_tiles_reverse_lookup[u.unit_state.unit_id] != t
		):
			u.mover.delay(T.get_timestamp_msec())
			
			state.m_commands.lock()
			
			state.engine_commands.append(
				Callable(self, "_issue_move").bind(
					u.unit_state.unit_id,
					u.mover.dst,
				),
			)
			
			state.m_commands.unlock()
