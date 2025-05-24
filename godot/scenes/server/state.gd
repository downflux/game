extends DFStateBase
class_name DFState

const _CACHE_LENGTH = 10

# Convenience lookup modules
@onready var players: Node = $Players


func to_dict(sid: int, filter: DFEnums.DataFilter, query: Dictionary) -> Dictionary:
	var q = query.get(DFStateKeys.KDFPlayers, {})
	
	if not q:
		return {}

	return {
		DFStateKeys.KDFPlayers: players.to_dict(sid, filter, q),
	}


var _cache: Array = [[], [], [], [], [], [], [], [], [], []]
var _index: int = 0 
var _filter: DFEnums.DataFilter = (
	DFEnums.DataFilter.FILTER_CURVES
	| DFEnums.DataFilter.FILTER_PLAYERS
)
var _query: Dictionary = DFQuery.generate(_filter).get(DFStateKeys.KDFState, {})


func get_state_by_timestamp(timestamp: int) -> Array:
	for offset in range(_CACHE_LENGTH):
		var i = (_index + 1 + offset) % _CACHE_LENGTH
		var j = (_index + 2 + offset) % _CACHE_LENGTH
		if _cache[i][0] < timestamp and _cache[j][0] > timestamp:
			return _cache[i]
	return []


func _get_state(offset: int) -> Dictionary:
	if offset >= _CACHE_LENGTH:  # Too far in the past.
		return {}
	
	var i := _index - offset
	if i < 0:
		i += _CACHE_LENGTH
	
	return _cache[i % _CACHE_LENGTH]

func _physics_process(_delta):
	var timestamp = Time.get_unix_time_from_system()
	var data = [
		timestamp,
		to_dict(1, _filter, _query),
	]
	
	_cache[_index] = data
	_index = (_index + 1) % _CACHE_LENGTH
