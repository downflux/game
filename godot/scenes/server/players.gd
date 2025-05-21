extends Node

func to_dict(sid: int, query: Dictionary) -> Dictionary:
	var data = {}
	for p in get_children():
		data[p.session_id] = p.to_dict(sid, query)
	
	return data
