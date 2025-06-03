class_name DFServerState
extends DFStateBase

# Convenience lookup modules
@onready var players: DFServerPlayers = $Players
@onready var units: DFServerUnits     = $Units
@onready var map: DFServerMap         = $Map

## The number of milliseconds since the server started.
var timestamp_msec: int


func to_dict(sid: int, partial: bool, query: Dictionary) -> Dictionary:
	var data = {
		DFStateKeys.KDFTimestampMSec: timestamp_msec,
	}
	
	Logger.debug("sid: %s, partial: %s, query: %s" % [str(sid), str(partial), str(query)])
	
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
	
	Logger.debug("data: %s" % str(data))
	return data


func _physics_process(_delta):
	timestamp_msec = Time.get_ticks_msec()
	
	# TODO(minkezhang): Implement state handling.
	
	is_dirty = false
