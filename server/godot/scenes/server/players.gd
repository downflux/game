class_name DFServerPlayers
extends DFStateBase


func add_player(player: DFServerPlayer):
	is_dirty = true
	
	player.reparent(self)


func get_player(sid: int) -> DFServerPlayer:
	return get_node(str(sid))


func to_dict(sid: int, partial: bool, query: Dictionary) -> Dictionary:
	if partial and not is_dirty:
		return {}
	
	var data = {}
	
	for p: DFServerPlayer in get_children():
		if partial and not p.is_dirty:
			continue
		
		data[p.session_id] = p.to_dict(sid, partial, query)
	
	return data
