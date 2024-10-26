extends Node2D


enum NavigationLayer {
	NAVIGATION_LAYER_GROUND,
	NAVICATION_LAYER_SEA,
}

func debug_get_navigation_layer(terrain_set: int, terrain: int):
	return {
		0: NavigationLayer.NAVIGATION_LAYER_GROUND,
		1: NavigationLayer.NAVICATION_LAYER_SEA,
	}[terrain]


func debug_get_tile_coordinates(local: Vector2) -> Vector2i:
	return $Terrain.local_to_map(local)


func _input(event: InputEvent):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton and event.pressed:
		var e = make_input_local(event)
		print("DEBUG(map_layer.gd): mouse click at: ", e.position)
		print("DEBUG(map_layer.gd): clicked on tile ", debug_get_tile_coordinates(e.position))
		var t = $Terrain.get_cell_tile_data(debug_get_tile_coordinates(e.position))
		if t != null:
			print("DEBUG(map_layer.gd): navication layer ", NavigationLayer.keys()[(debug_get_navigation_layer(
				t.get_terrain_set(),
				t.get_terrain(),
			))])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
