extends Node
class_name DFStateBase

var is_dirty: bool:
	set(v):
		is_dirty = v
	get:
		return is_dirty


func to_dict(
	sid: int,
	filter: DFEnums.DataFilter,
	query: Dictionary
) -> Dictionary:
	Logger.error("to_dict not implemented")
	
	return {}
