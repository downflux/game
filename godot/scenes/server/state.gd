extends Node
class_name DFState

# Convenience lookup modules
@onready var players: Node = $Players

enum Filter {
	FILTER_NONE           = 0,
	FILTER_PLAYER_STATIC  = 1,
	FILTER_PLAYER_DYNAMIC = 2,
	FILTER_UNIT_STATIC    = 4,
	FILTER_UNIT_DYNAMIC   = 8,
 }

func to_dict(sid: int, query: Dictionary) -> Dictionary:
	return {
		DFStateKeys.KDFState: {
			DFStateKeys.KDFPlayers: players.to_dict(sid, query.get(
				DFStateKeys.KDFPlayers, {},
			)),
			DFStateKeys.KDFUnits: {},
			DFStateKeys.KDFBuildings: {},
		},
	}
