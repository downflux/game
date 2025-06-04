class_name DFClientUnitBase
extends DFStateBase

@export var unit_state: DFUnitBase
@export var sprite: Sprite2D


var _cell_size: Vector2   = Vector2(32, 16)
var _cell_offset: Vector2 = _cell_size / 2


func _map_to_local(g: Vector2) -> Vector2:
	return Vector2(
		_cell_offset.x * (g.y + g.x) + _cell_offset.x,
		_cell_offset.y * (g.y - g.x) + _cell_offset.y,
	)


func _process(_delta):
	var p = _map_to_local(
		unit_state.position.get_value(Server.get_server_timestamp_msec()),
	)
	sprite.position = p


func from_dict(
	partial: bool,
	data: Dictionary,
):
	if DFStateKeys.KDFIsFreed in data:
		self.is_deleted = true
		return
	
	unit_state.from_dict(partial, data)
