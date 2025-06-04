class_name DFClientUnitBase
extends DFStateBase

@export var unit_state: DFUnitBase


func from_dict(
	partial: bool,
	data: Dictionary,
):
	if DFStateKeys.KDFIsFreed in data:
		self.is_deleted = true
		return
	
	unit_state.from_dict(partial, data)
