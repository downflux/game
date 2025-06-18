class_name DFServerUnits
extends DFStateBase


func add_unit(unit: DFServerUnitBase):
	is_dirty = true
	
	unit.reparent(self)


func get_unit(uid: int) -> DFServerUnitBase:
	return get_node_or_null(str(uid))


func to_dict(sid: int, partial: bool, query: Dictionary) -> Dictionary:
	if partial and not is_dirty:
		return {}
	
	var data = {}
	
	for u: Node in get_children():
		if (
			u is not DFServerUnitBase
		) or (
			partial and not u.is_dirty
		):
			continue
		
		data[u.unit_state.unit_id] = u.to_dict(sid, partial, query)
	
	return data
