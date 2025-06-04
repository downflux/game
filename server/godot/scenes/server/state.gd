class_name DFServerState
extends DFStateBase

# Convenience lookup modules
@onready var players: DFServerPlayers = $Players
@onready var units: DFServerUnits     = $Units
@onready var map: DFServerMap         = $Map

## The number of milliseconds since the server started.
var timestamp_msec: int


func get_vector_path(uid: int, dst: Vector2i) -> Array[Vector2i]:
	var u: DFServerUnitBase = units.get_unit(uid)
	var t: int = u.unit_state.x.get_window_end_timestamp(timestamp_msec)
	if t == -1:
		t = timestamp_msec
	
	var src: Vector2 = Vector2(
		u.unit_state.x.get_value(t),
		u.unit_state.y.get_value(t),
	)
	
	return map.get_vector_path(src, dst, u.unit_state.map_layer.get_value(t))


func set_vector_path(uid: int, path: Array[Vector2i]):
	units.get_unit(uid).get_node("Walker").set_vector_path(
		timestamp_msec,
		path,
	)


func to_dict(sid: int, partial: bool, query: Dictionary) -> Dictionary:
	var data = {
		DFStateKeys.KDFTimestampMSec: timestamp_msec,
	}
	
	if partial and not is_dirty:
		return data
	
	if DFStateKeys.KDFPlayers in query and (
		players.is_dirty or not partial
	):
		data[DFStateKeys.KDFPlayers] = players.to_dict(sid, partial, query[DFStateKeys.KDFPlayers])
	
	if DFStateKeys.KDFUnits in query and (
		units.is_dirty or not partial
	):
		data[DFStateKeys.KDFUnits] = units.to_dict(sid, partial, query[DFStateKeys.KDFUnits])
	
	return data


func _physics_process(_delta):
	timestamp_msec = Time.get_ticks_msec()
	
	# TODO(minkezhang): Implement state handling.
	
	is_dirty = false
