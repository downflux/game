class_name DFServerUnitBase
extends DFStateBase

@export var unit_state: DFUnitBase

# Composables

@export var mover: DFServerMoverBase


func _ready():
	if mover == null:
		mover = DFServerMoverBase.new()
		add_child(mover)


func to_dict(
	sid: int,
	partial: bool,
	query: Dictionary,
) -> Dictionary:
	if partial and not is_dirty:
		return {}
	
	return unit_state.to_dict(sid, partial, query)
