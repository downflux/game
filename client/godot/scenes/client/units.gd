class_name DFClientUnits
extends DFStateBase

@export var camera: DFClientCamera
@export var players: DFClientPlayers

@onready var selector: DFUnitSelector = $Selector
@onready var unit_scene_lookup: Dictionary[DFEnums.UnitType, PackedScene] = {
	DFEnums.UnitType.UNIT_GI: preload("res://scenes/instances/units/gi.tscn"),
}

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
		var u: DFClientUnitBase = get_unit(uid)
		if u != null and u.unit_state.faction == p.player_state.faction:
			u.ui.select(state)


func _on_unit_paths_received(paths: Dictionary):
	for u: DFClientUnitBase in get_children().filter(
		func(u): return u is DFClientUnitBase):
		u.directive.visible = (
			u.directive.visible
		) and (
			u.unit_state.unit_id in paths
		)
	
	for uid in paths:
		var u: DFClientUnitBase = get_unit(uid)
		if u == null or not paths[uid]:
			return
		u.directive.dst = DFGeo.to_local(
			paths[uid][-1],
		)
		u.directive.start_timer()


func add_unit(unit: DFClientUnitBase):
	is_dirty = true
	
	unit.ui.collider.mouse_entered.connect(
		func(): _on_unit_mouse_entered(unit.unit_state.unit_id),
	)
	unit.ui.collider.mouse_exited.connect(
		func(): _on_unit_mouse_exited(unit.unit_state.unit_id),
	)
	
	add_child(unit, true)


func get_unit(uid: int) -> DFClientUnitBase:
	return get_node_or_null(str(uid))


func from_dict(
	partial: bool,
	data: Dictionary,
):
	for uid in data:
		var u: DFClientUnitBase = get_unit(uid)
		if u == null:
			u = unit_scene_lookup[data[uid][DFStateKeys.KDFUnitType]].instantiate()
			u.name = str(uid)
			
			add_unit(u)
		u.from_dict(partial, data[uid])


func _ready():
	Server.unit_paths_received.connect(_on_unit_paths_received)


func _input(event: InputEvent):
	if event.is_action_pressed("select_unit"):
		if _mouseover_uid != -1 and not _selected_uids:
			_selected_uids = [_mouseover_uid]
			_select_units(_selected_uids, true)
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("interact_position"):
		if _mouseover_uid == -1 and _selected_uids:
			var d = DFGeo.to_grid(selector.get_global_mouse_position())
			print("len selected uids: %d; len children: %d" % [len(_selected_uids), len(get_children()) - 1])
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
	
	var selected = get_viewport(
		).get_world_2d(
		).direct_space_state.intersect_shape(
		query,
		_MAX_SELECTED_UNITS,
	)
	
	var uids: Array[int] = []
	for s in selected:
		uids.append(s["collider"].unit_id)
	
	return uids
