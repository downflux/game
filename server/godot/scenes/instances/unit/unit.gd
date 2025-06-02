class_name DFServerUnitBase
extends DFStateBase

@onready var unit_state: DFUnitBase = $UnitState

# Server-populated vars.
#
# These are not visible to other players and therefore not tracked by is_dirty.

var unit_id: int


func to_dict(
	sid: int,
	partial: bool,
	query: Dictionary,
) -> Dictionary:
	if partial and not is_dirty:
		return {}
	
	return unit_state.to_dict(sid, partial, query)
