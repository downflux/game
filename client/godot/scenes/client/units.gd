class_name DFClientUnits
extends DFStateBase


@onready var unit_scene_lookup: Dictionary[DFEnums.UnitType, PackedScene] = {
	DFEnums.UnitType.UNIT_GI: preload("res://scenes/instances/units/gi.tscn"),
}


func add_unit(unit: DFClientUnitBase):
	is_dirty = true
	
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
