extends DFStateBase
class_name DFState

const _CACHE_LENGTH = 10

# Convenience lookup modules
@onready var players: Node = $Players


func to_dict(sid: int, full: bool, query: Dictionary) -> Dictionary:
	if not full and not is_dirty:
		return {}
	
	var q = query.get(DFStateKeys.KDFPlayers, {})
	if not q:
		return {}

	return {
		DFStateKeys.KDFPlayers: players.to_dict(sid, full, q),
	}
