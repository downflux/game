class_name DFClientUnits
extends DFStateBase

signal unit_added(u: DFClientUnitBase)

@onready var unit_scene_lookup: Dictionary[DFEnums.UnitType, PackedScene] = {
	DFEnums.UnitType.UNIT_GI: preload("res://scenes/instances/units/gi.tscn"),
}


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
	
	add_child(unit, true)
	unit_added.emit(unit)


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
