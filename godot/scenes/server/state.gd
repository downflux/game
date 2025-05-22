extends DFStateBase
class_name DFState

# Convenience lookup modules
@onready var players: Node = $Players


func to_dict(sid: int, filter: DFEnums.DataFilter, query: Dictionary) -> Dictionary:
	var data = {
		DFStateKeys.KDFState: {
		}
	}
	
	var q = query.get(DFStateKeys.KDFPlayers, {})
	if q:
		data[DFStateKeys.KDFState] = {
			DFStateKeys.KDFPlayers: players.to_dict(sid, filter, q),
		}
	else:
		data[DFStateKeys.KDFState] = {}
	
	return data
