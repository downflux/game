extends Node

# Convenience lookup modules
@onready var players: Node = $Players

enum Filter {
	FILTER_NONE           = 0,
	FILTER_PLAYER_STATIC  = 1,
	FILTER_PLAYER_DYNAMIC = 2,
	FILTER_UNIT_STATIC    = 4,
	FILTER_UNIT_DYNAMIC   = 8,
 }

func to_dict(permissions: DFEnums.Permission, filters: Filter) -> Dictionary:
	var state = {
		DFStateKeys.ServerTimestamp: Time.get_unix_time_from_system(),
	}
	
	
	if filters & Filter.FILTER_PLAYER_STATIC:
		var ps = {}
		for p in players.get_children():
			ps.merge({
				p.session_id: p.to_dict(permissions),
			})
		state.merge({
			DFStateKeys.Players: ps,
		})
	
	return state
