class_name DFUnitSelectorInput
extends Node2D

@export var camera: DFClientCamera
@export var players: DFClientPlayers
@export var units: DFClientUnits
@export var selector: DFUnitSelector

const _MAX_SELECTED_UNITS: int = 128

var _selected_uids: Array[int]
var _mouseover_uid: int = -1


func _on_unit_mouse_entered(uid: int):
	_mouseover_uid = uid


func _on_unit_mouse_exited(_uid: int):
	_mouseover_uid = -1


func _select_units(uids: Array[int], state: bool):
	var p: DFClientPlayer = players.get_self()
	if p == null:
		return
	for uid: int in uids:
		var u: DFClientUnitBase = units.get_unit(uid)
		if u != null and u.unit_state.faction == p.player_state.faction:
			u.ui.select(state)


func _on_unit_added(u: DFClientUnitBase):
	u.ui.collider.mouse_entered.connect(
		func(): _on_unit_mouse_entered(u.unit_state.unit_id),
	)
	u.ui.collider.mouse_exited.connect(
		func(): _on_unit_mouse_exited(u.unit_state.unit_id),
	)


func _ready():
	units.unit_added.connect(_on_unit_added)


func _input(event: InputEvent):
	if event.is_action_pressed("select_unit"):
		if _mouseover_uid != -1 and not _selected_uids:
			_selected_uids = [_mouseover_uid]
			_select_units(_selected_uids, true)
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("interact_position"):
		if _mouseover_uid == -1 and _selected_uids:
			var d = DFGeo.to_grid(get_global_mouse_position())
			Server.s_issue_move.rpc_id(1, _selected_uids, d)
		get_viewport().set_input_as_handled()
	
	if event.is_action_released("interact_cancel") and not camera.get_pan():
		_select_units(_selected_uids, false)
		_selected_uids = []
	
	if event.is_action_pressed("select_unit_box"):
		if _mouseover_uid == -1 and not _selected_uids:
			selector.set_pan(true)
			get_viewport().set_input_as_handled()
	if event.is_action_released("select_unit_box"):
		if selector.get_pan():
			_select_units(_selected_uids, false)
			_selected_uids = _intersect_uids()
			_select_units(_selected_uids, true)
			selector.set_pan(false)
			get_viewport().set_input_as_handled()


func _intersect_uids() -> Array[int]:
	var r: RectangleShape2D = RectangleShape2D.new()
	r.size = (selector.dst - selector.src).abs()
	var query = PhysicsShapeQueryParameters2D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = 1  # Units only
	query.set_shape(r)
	query.transform = Transform2D(0, (selector.src + selector.dst) / 2)
	
	var selected = get_world_2d(
		).direct_space_state.intersect_shape(
		query,
		_MAX_SELECTED_UNITS,
	)
	
	var uids: Array[int] = []
	for s in selected:
		uids.append(s["collider"].unit_id)
	
	return uids
