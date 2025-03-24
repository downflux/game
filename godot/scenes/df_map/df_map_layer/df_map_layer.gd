extends Node2D
class_name DFMapLayer


var _src = Vector2i(0, 0)
var _dst = Vector2i(0, 0)


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
	
	# Move from current position to mouse click.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_released():
			var e = make_input_local(event)
			_src = $DFUnit.head
			_dst = debug_get_tile_coordinates(e.position)
			var _layer = get_tile_layer(_src)
			
			var p = $DFNavigation.get_id_path(_layer, _src, _dst, true)
			$DFUnit.move(p)
			$DFNavigationUI.show_path(
				$DFNavigation.get_id_path(_layer, _src, _dst, true),
			)
	
	# Teleport
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_released():
			var e = make_input_local(event)
			_dst = debug_get_tile_coordinates(e.position)
			$DFUnit.position = _dst
			$DFNavigationUI.show_path([])


func _ready():
	$DFNavigation.set_region($DFTerrain.get_used_rect())
	
	# Set up pathfinding layers
	for c in $DFTerrain.get_used_cells():
		$DFNavigation.set_point_solid(get_tile_layer(c), c, false)
