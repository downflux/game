class_name DFClientController
extends Node2D


enum _ClickState {
	CLICK_STATE_NONE,
	CLICK_STATE_SELECT,
	CLICK_STATE_SELECT_DRAG,
	CLICK_STATE_INTERACT,
}

var _click_state: _ClickState

@export var units: DFClientUnits
@export var selection_box: DFSelectionBox

var _uids: Array[int]
var _candidate_uids: Array[int]


func _select_units(uids: Array[int], select: bool):
	for uid in uids:
		var u: DFClientUnitBase = units.get_unit(uid)
		if u != null:
			u.ui.select(select)


func _on_unit_mouse_entered(uid: int):
	_candidate_uids = [uid]


func _on_unit_mouse_exited(uid: int):
	_candidate_uids = []


func _process(delta):
	Logger.debug(_ClickState.keys()[_click_state])


func _ready():
	units.unit_mouse_entered.connect(_on_unit_mouse_entered)
	units.unit_mouse_exited.connect(_on_unit_mouse_exited)


func _input(event: InputEvent):
	# Mouse in viewport coordinates.
	
	# Move from current position to mouse click.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			match _click_state:
				_ClickState.CLICK_STATE_NONE:
					if _candidate_uids:
						_click_state = _ClickState.CLICK_STATE_INTERACT
						_uids = _candidate_uids
						_candidate_uids = []
						_select_units(_uids, true)
					else:
						_click_state = _ClickState.CLICK_STATE_SELECT_DRAG
						selection_box.start = get_global_mouse_position()
						selection_box.end = get_global_mouse_position()
						selection_box.visible = true
				_ClickState.CLICK_STATE_INTERACT:
					if _candidate_uids:
						# TODO(minkezhang): Attack.
						pass
					else:
						var e = make_input_local(event)
						var dst = DFGeo.to_grid(e.position)
						
						Logger.info("%s request move to %s" % [_uids, dst])
						
						Server.s_issue_move.rpc_id(1, _uids, dst)
		if event.is_released():
			match _click_state:
				_ClickState.CLICK_STATE_SELECT_DRAG:
						_click_state = _ClickState.CLICK_STATE_INTERACT
						_uids = _candidate_uids
						_candidate_uids = []
						_select_units(_uids, true)
						_get_selected_units()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed():
			match _click_state:
				_ClickState.CLICK_STATE_SELECT_DRAG:
					_uids = []
					_get_selected_units()
		_click_state = _ClickState.CLICK_STATE_NONE
		_select_units(_uids, false)
	if event is InputEventMouseMotion:
		match _click_state:
			_ClickState.CLICK_STATE_SELECT_DRAG:
				selection_box.end = get_global_mouse_position()


func _get_selected_units():
	var r: RectangleShape2D = RectangleShape2D.new()
	r.size = (selection_box.end - selection_box.start).abs()
	
	var query = PhysicsShapeQueryParameters2D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = 1
	query.set_shape(r)
	query.transform = Transform2D(0, (selection_box.end + selection_box.start) / 2)
	
	var selected = get_world_2d().direct_space_state.intersect_shape(query)
	
	selection_box.visible = false
	
	_uids = []
	for s in selected:
		_uids.append(s["collider"].unit_id)
	_select_units(_uids, true)
