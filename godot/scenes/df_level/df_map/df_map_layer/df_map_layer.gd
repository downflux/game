extends Node2D
class_name DFMapLayer


var _src = Vector2i(0, 0)
var _dst = Vector2i(0, 0)
var _layer = DFNavigation.L.LAYER_UNKNOWN


func debug_get_tile_coordinates(local: Vector2) -> Vector2i:
	return $DFTerrain.local_to_map(local)


func _input(event: InputEvent):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton and event.pressed:
		var e = make_input_local(event)
		_src = debug_get_tile_coordinates(e.position)
		if $DFTerrain.get_cell_tile_data(_src).get_custom_data("TraversibleSea"):
			_layer = DFNavigation.L.LAYER_SEA
		if $DFTerrain.get_cell_tile_data(_src).get_custom_data("TraversibleGround"):
			_layer = DFNavigation.L.LAYER_GROUND
	if event is InputEventMouseButton and event.is_released():
		var e = make_input_local(event)
		_dst = debug_get_tile_coordinates(e.position)
		$DFNavigationUI.show_path(
			$DFNavigation.get_id_path(
				_layer,
				_src,
				_dst,
				true,
			),
		)
		_layer = DFNavigation.L.LAYER_UNKNOWN



func _ready():
	$DFNavigation.set_region($DFTerrain.get_used_rect())
	
	# Set up pathfinding layers
	for c in $DFTerrain.get_used_cells():
		var l = DFNavigation.L.LAYER_UNKNOWN
		var g = $DFTerrain.get_cell_tile_data(c).get_custom_data("TraversibleGround")
		var s = $DFTerrain.get_cell_tile_data(c).get_custom_data("TraversibleSea")
		if g and s:
			l = DFNavigation.L.LAYER_AMPHIBIOUS
		elif g:
			l = DFNavigation.L.LAYER_GROUND
		elif s:
			l = DFNavigation.L.LAYER_SEA
		$DFNavigation.set_point_solid(l, c, false)
