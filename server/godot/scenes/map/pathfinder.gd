class_name DFPathfinder
extends Node


var _pathfinder: AStarGrid2D = AStarGrid2D.new()


func configure_pf(region: Rect2i, map_layer: DFEnums.MapLayer):
	_pathfinder.set_region(region)
	
	match map_layer:
		DFEnums.MapLayer.LAYER_SEA:
			_pathfinder.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
		_:
			_pathfinder.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_AT_LEAST_ONE_WALKABLE
	
	_pathfinder.update()


func set_solid(target: Variant, solid: bool):
	if target is Rect2i:
		_pathfinder.fill_solid_region(target, solid)
	elif target is Vector2i:
		_pathfinder.set_point_solid(target, solid)


func get_vector_path(src: Vector2i, dst: Vector2i) -> Array[Vector2i]:
	return _pathfinder.get_id_path(src, dst, true)
