class_name DFClientController
extends Node2D


@export var units: DFClientUnits

var _uids: Array[int]
var _candidate_uids: Array[int]

func _select_units(uids: Array[int], select: bool):
	for uid in _uids:
		var u: DFClientUnitBase = units.get_unit(uid)
		if u != null:
			u.ui.select(select)


func _on_unit_mouse_entered(uid: int):
	_candidate_uids = [uid]

func _on_unit_mouse_exited(uid: int):
	_candidate_uids = []


func _ready():
	units.unit_mouse_entered.connect(_on_unit_mouse_entered)
	units.unit_mouse_exited.connect(_on_unit_mouse_exited)


func _input(event: InputEvent):
	# Mouse in viewport coordinates.
	
	# Move from current position to mouse click.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_released():
			if not _uids:
				_uids = _candidate_uids
				_select_units(_uids, true)
				
			else:
				var e = make_input_local(event)
				var dst = DFGeo.to_grid(e.position)
				
				Logger.info("%s request move to %s" % [_uids, dst])
				
				Server.s_issue_move.rpc_id(1, _uids, dst)
	
	# Teleport
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_released():
			if _uids:
				_select_units(_uids, false)
				_uids = []
			else:
				var e = make_input_local(event)
			# dst = debug_get_tile_coordinates(e.position)
			# $DFUnit.position = dst
