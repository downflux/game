class_name DFState
extends DFStateBase

# Convenience lookup modules
@onready var players: DFPlayers = $Players

## The number of milliseconds since the server started.
var timestamp_msec: int


func to_dict(sid: int, partial: bool, query: Dictionary) -> Dictionary:
	var data = {
		DFStateKeys.KDFTimestampMSec: timestamp_msec,
	}
	
	if partial and not is_dirty:
		return data
	
	var q = query.get(DFStateKeys.KDFPlayers, {})
	if q:
		data[DFStateKeys.KDFPlayers] = players.to_dict(sid, partial, q)
	
	return data


func _physics_process(_delta):
	timestamp_msec = Time.get_ticks_msec()
	
	# TODO(minkezhang): Implement state handling.
	
	is_dirty = false
