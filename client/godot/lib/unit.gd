class_name DFClientUnitBase
extends DFStateBase

@export var unit_state: DFUnitBase
@export var directive: DFUnitDirective
@export var ui: DFUnitUIBase


func _process(_delta):
	var p = DFGeo.to_local(
		unit_state.position.get_value(Server.get_server_timestamp_msec()),
	)
	ui.position = p
	directive.src = p + ui.sprite.position


func from_dict(
	partial: bool,
	data: Dictionary,
):
	if DFStateKeys.KDFIsFreed in data:
		self.is_deleted = true
		return
	
	unit_state.from_dict(partial, data)
