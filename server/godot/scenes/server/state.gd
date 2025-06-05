class_name DFServerState
extends DFStateBase

# Convenience lookup modules
@onready var players: DFServerPlayers = $Players
@onready var units: DFServerUnits     = $Units
@onready var map: DFServerMap         = $Map

## The number of milliseconds since the server started.
var timestamp_msec: int


var user_commands: Dictionary[int, Callable] = {}
var commands: Array[Callable]
var m_commands: Mutex = Mutex.new()


func enqueue_user_command(sid: int, f: Callable):
	m_commands.lock()
	user_commands[sid] = f
	m_commands.unlock()


func get_vector_path(uid: int, dst: Vector2i) -> Array[Vector2i]:
	var u: DFServerUnitBase = units.get_unit(uid)
	if u == null:
		return []
	
	var t: int = u.unit_state.position.get_window_end_timestamp(timestamp_msec)
	if t == -1:
		t = timestamp_msec
	
	return map.get_vector_path(
		u.unit_state.position.get_value(t),
		dst,
		u.unit_state.map_layer.get_value(t),
	)


func set_vector_path(uid: int, path: Array[Vector2i]):
	var u: DFServerUnitBase = units.get_unit(uid)
	if u == null:
		return
	
	u.mover.set_vector_path(timestamp_msec, path)


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
	is_dirty = false

	m_commands.lock()
	
	for sid: int in user_commands:
		user_commands[sid].call()
	user_commands = {}
	for c: Callable in commands:
		c.call()
	commands = []
	
	m_commands.unlock()
