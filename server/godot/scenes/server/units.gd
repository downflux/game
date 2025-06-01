class_name DFUnits
extends DFStateBase

var _uid: int = 0


func _generate_unit_id() -> int:
	var uid = _uid + 1
	_uid += 1
	return uid


func add_unit(unit: DFUnitBase):
	unit.uid = _generate_unit_id()
	unit.name = str(unit.uid)
	add_child(unit, true)


func get_unit(uid: int) -> DFUnitBase:
	return get_node(str(uid))


func to_dict(sid: int, partial: bool, query: Dictionary) -> Dictionary:
	if partial and not is_dirty:
		return {}
	
	var data = {}
	
	for u: DFUnitBase in get_children():
		if partial and not u.is_dirty:
			continue
		
		data[u.uid] = u.to_dict(sid, partial, query)
	
	return data
