extends Node2D
class_name DFMapLayer


var _from_id = Vector2i(0, 0)
var _to_id = Vector2i(0, 0)


func debug_get_tile_coordinates(local: Vector2) -> Vector2i:
	return $DFTerrain.local_to_map(local)


func _input(event: InputEvent):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton and event.pressed:
		var e = make_input_local(event)
		_from_id = debug_get_tile_coordinates(e.position)
	if event is InputEventMouseButton and event.is_released():
		var e = make_input_local(event)
		_to_id = debug_get_tile_coordinates(e.position)
		$DFNavigationUI.show_path(
			$DFNavigation.get_id_path(
				DFNavigation.Layer.LAYER_GROUND,
				_from_id,
				_to_id,
				true,
			),
		)

func _ready():
	$DFNavigation.set_region($DFTerrain.get_used_rect())
	
	# Set up pathfinding layers
	for c in $DFTerrain.get_used_cells():
		var l = DFNavigation.Layer.LAYER_UNKNOWN
		if $DFTerrain.get_cell_tile_data(c).get_custom_data("TraversibleGround"):
			l |= DFNavigation.Layer.LAYER_GROUND
		if $DFTerrain.get_cell_tile_data(c).get_custom_data("TraversibleSea"):
			l |= DFNavigation.Layer.LAYER_SEA
		$DFNavigation.set_point_solid(l, c, false)
