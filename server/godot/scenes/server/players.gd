class_name DFPlayers
extends DFStateBase


func add_player(player: DFPlayer):
	player.name = str(player.session_id)
	add_child(player, true)


func get_player(sid: int) -> DFPlayer:
	return get_node(str(sid))


func to_dict(sid: int, partial: bool, query: Dictionary) -> Dictionary:
	if partial and not is_dirty:
		return {}
	
	var data = {}
	
	for p: DFPlayer in get_children():
		if partial and not p.is_dirty:
			continue
		
		data[p.session_id] = p.to_dict(sid, partial, query)
	
	return data
