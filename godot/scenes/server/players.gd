extends DFStateBase


func to_dict(sid: int, filter: DFEnums.DataFilter, query: Dictionary) -> Dictionary:
	var data = {}
	
	for p in get_children():
		data[p.session_id] = p.to_dict(sid, filter, query)
	
	return data
