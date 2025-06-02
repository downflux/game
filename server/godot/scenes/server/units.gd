class_name DFServerUnits
extends DFStateBase

var _uid: int = 0


func _generate_unit_id() -> int:
	var uid = _uid + 1
	_uid += 1
	return uid


func add_unit(unit: DFServerUnitBase):
	unit.unit_id = _generate_unit_id()
	unit.name = str(unit.unit_id)
	add_child(unit, true)


func get_unit(uid: int) -> DFServerUnitBase:
	return get_node(str(uid))


func to_dict(sid: int, partial: bool, query: Dictionary) -> Dictionary:
	if partial and not is_dirty:
		return {}
	
	var data = {}
	
	for u: DFServerUnitBase in get_children():
		if partial and not u.is_dirty:
			continue
		
		data[u.unit_id] = u.to_dict(sid, partial, query)
	
	return data
