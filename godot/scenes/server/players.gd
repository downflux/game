extends DFStateBase


func to_dict(sid: int, full: bool, query: Dictionary) -> Dictionary:
	if not full and not is_dirty:
		return {}
	
	var data = {}
	
	for p in get_children():
		data[p.session_id] = p.to_dict(sid, full, query)
	
	return data
