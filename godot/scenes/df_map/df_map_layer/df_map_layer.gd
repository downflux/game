extends Node2D
class_name DFMapLayer


var _src = Vector2i(0, 0)
var _dst = Vector2i(0, 0)
var _layer = DFNavigation.L.LAYER_UNKNOWN


func debug_get_tile_coordinates(local: Vector2) -> Vector2i:
	return $DFTerrain.local_to_map(local)


func get_tile_layer(id: Vector2i) -> DFNavigation.L:
	var t = $DFTerrain.get_cell_tile_data(id)
	var l = DFNavigation.L.LAYER_UNKNOWN
	if t != null:
		var g = t.get_custom_data("TraversibleGround")
		var s = t.get_custom_data("TraversibleSea")
		if g and s:
			l = DFNavigation.L.LAYER_AMPHIBIOUS
		elif g:
			l = DFNavigation.L.LAYER_GROUND
		elif s:
			l = DFNavigation.L.LAYER_SEA
	return l


func _input(event: InputEvent):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var e = make_input_local(event)
			_src = debug_get_tile_coordinates(e.position)
			print("DEBUG(df_map_layer.gd:_input): position = ", e.position, ", _src = ", _src, " $DFTerrain.position = ", $DFTerrain.position)
			_layer = get_tile_layer(_src)
		if event.is_released():
			var e = make_input_local(event)
			_dst = debug_get_tile_coordinates(e.position)
			var p = $DFNavigation.get_id_path(_layer, _src, _dst, true)
			# $DFUnit.position = $DFTerrain.map_to_local(p[0])
			$DFUnit.move(p)  # DEBUG
			$DFNavigationUI.show_path(
				$DFNavigation.get_id_path(_layer, _src, _dst, true),
			)
			_layer = DFNavigation.L.LAYER_UNKNOWN


func _ready():
	$DFNavigation.set_region($DFTerrain.get_used_rect())
	
	# Set up pathfinding layers
	for c in $DFTerrain.get_used_cells():
		$DFNavigation.set_point_solid(get_tile_layer(c), c, false)
