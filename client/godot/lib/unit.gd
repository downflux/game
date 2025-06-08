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
	directive.src = p


func from_dict(
	partial: bool,
	data: Dictionary,
):
	if DFStateKeys.KDFIsFreed in data:
		self.is_deleted = true
		return
	
	if DFStateKeys.KDFUnitID in data and not partial:
		ui.collider.unit_id = data[DFStateKeys.KDFUnitID]
	
	unit_state.from_dict(partial, data)


func _on_mouse_entered():
	Logger.debug("mouse entered unit %s" % [unit_state.unit_id])


func _on_mouse_exited():
	Logger.debug("mouse exited unit %s" % [unit_state.unit_id])


func _ready():
	ui.collider.mouse_entered.connect(_on_mouse_entered)
	ui.collider.mouse_exited.connect(_on_mouse_exited)
