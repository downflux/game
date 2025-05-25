class_name DFPlayers
extends DFStateBase


func get_player(sid: int) -> DFPlayer:
	return get_node(str(sid))


func to_dict(sid: int, partial: bool, query: Dictionary) -> Dictionary:
	if partial and not is_dirty:
		return {}
	
	var data = {}
	
	for p in get_children():
		if partial and not p.is_dirty:
			continue
		
		data[p.session_id] = p.to_dict(sid, partial, query)
	
	return data
