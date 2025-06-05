class_name DFClientUnitBase
extends DFStateBase

@export var unit_state: DFUnitBase
@export var sprite: Sprite2D
@export var directive: DFUnitDirective


func _process(_delta):
	var p = DFGeo.to_local(
		unit_state.position.get_value(Server.get_server_timestamp_msec()),
	)
	sprite.position = p
	directive.src = p


func from_dict(
	partial: bool,
	data: Dictionary,
):
	if DFStateKeys.KDFIsFreed in data:
		self.is_deleted = true
		return
	
	unit_state.from_dict(partial, data)
