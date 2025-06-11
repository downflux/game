class_name DFClientInputState
extends Node2D

enum ClickState {
	CLICK_STATE_NONE,
	CLICK_STATE_ERROR,
	
	CLICK_STATE_SELECTED,
	CLICK_STATE_DRAG,
	CLICK_STATE_DRAG_CONFIRM,
	CLICK_STATE_PAN,
	CLICK_STATE_PAN_CANCEL,
	CLICK_STATE_INTERACT,
}

enum MouseInput {
	MOUSE_INPUT_PRIMARY_DOWN,
	MOUSE_INPUT_PRIMARY_UP,
	MOUSE_INPUT_SECONDARY_DOWN,
	MOUSE_INPUT_SECONDARY_UP,
	MOUSE_INPUT_PAN,
}

var _mouseover_uid: int = -1
var _selected_uids: Array[int] = []
var _state_cache: ClickState = ClickState.CLICK_STATE_NONE:
	set(v):
		Logger.debug("setting input state %s --> %s" % [
			ClickState.keys()[_state_cache],
			ClickState.keys()[v],
		])
		_state_cache = v

@export var units: DFClientUnits
@export var camera: DFClientCamera
@export var selection_box: DFSelectionBox


func mouseover_unit() -> DFClientUnitBase:
	return units.get_unit(_mouseover_uid) if _mouseover_uid != -1 else null


func selected_units() -> Array[DFClientUnitBase]:
	return _selected_uids.map(func(uid): units.get_unit(uid))


func get_target_state(
	mouse_input: MouseInput,
) -> ClickState:
	if mouse_input == MouseInput.MOUSE_INPUT_SECONDARY_DOWN:
		if _state_cache == ClickState.CLICK_STATE_NONE:
			return ClickState.CLICK_STATE_PAN
		return ClickState.CLICK_STATE_NONE
	
	if mouse_input == MouseInput.MOUSE_INPUT_SECONDARY_UP:
		if _state_cache == ClickState.CLICK_STATE_PAN:
			return ClickState.CLICK_STATE_PAN_CANCEL
	
	if mouse_input == MouseInput.MOUSE_INPUT_PRIMARY_DOWN:
		if _selected_uids:
			return ClickState.CLICK_STATE_INTERACT
		if _mouseover_uid != -1:
			return ClickState.CLICK_STATE_SELECTED
		if _mouseover_uid == -1:
			return ClickState.CLICK_STATE_DRAG
	
	if mouse_input == MouseInput.MOUSE_INPUT_PRIMARY_UP:
		if _state_cache == ClickState.CLICK_STATE_DRAG:
			return ClickState.CLICK_STATE_DRAG_CONFIRM
	
	return _state_cache


func _process(_delta):
	match _state_cache:
		ClickState.CLICK_STATE_DRAG:
			selection_box.end = get_global_mouse_position()
		ClickState.CLICK_STATE_PAN:
			pass  # TODO


func _on_unit_mouse_entered(uid: int):
	_mouseover_uid = uid


func _on_unit_mouse_exited(uid: int):
	_mouseover_uid = -1


func _ready():
	units.unit_mouse_entered.connect(_on_unit_mouse_entered)
	units.unit_mouse_exited.connect(_on_unit_mouse_exited)


func handle_mouse_input(mouse_input: MouseInput):
	var dst = get_target_state(mouse_input)
	if dst == _state_cache:
		return
	
	_state_cache = dst
	
	match dst:
		ClickState.CLICK_STATE_NONE:
			units.select_units(_selected_uids, false)
			_selected_uids = []
		ClickState.CLICK_STATE_DRAG:
			selection_box.start = get_global_mouse_position()
			selection_box.end = get_global_mouse_position()
			selection_box.visible = true
		ClickState.CLICK_STATE_SELECTED:
			units.select_units(_selected_uids, false)
			_selected_uids = [_mouseover_uid]
			units.select_units(_selected_uids, true)
		ClickState.CLICK_STATE_INTERACT:
			var d = DFGeo.to_grid(get_global_mouse_position())
			Server.s_issue_move.rpc_id(1, _selected_uids, d)
		ClickState.CLICK_STATE_DRAG_CONFIRM:
			units.select_units(_selected_uids, false)
			_selected_uids = _intersect_uids()
			units.select_units(_selected_uids, true)
			selection_box.visible = false
			_state_cache = ClickState.CLICK_STATE_NONE
		ClickState.CLICK_STATE_PAN_CANCEL:
			camera.set_pan(false)
			_state_cache = ClickState.CLICK_STATE_NONE
		ClickState.CLICK_STATE_PAN:
			camera.set_pan(true)


func _intersect_uids() -> Array[int]:
	var r: RectangleShape2D = RectangleShape2D.new()
	r.size = (selection_box.end - selection_box.start).abs()
	
	var query = PhysicsShapeQueryParameters2D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = 1
	query.set_shape(r)
	query.transform = Transform2D(0, (selection_box.end + selection_box.start) / 2)
	
	var selected = get_world_2d().direct_space_state.intersect_shape(query)
	
	var uids: Array[int] = []
	for s in selected:
		uids.append(s["collider"].unit_id)
	
	return uids
