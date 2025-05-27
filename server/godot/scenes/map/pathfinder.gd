class_name DFPathfinder
extends Node


@export var map_layer: DFServerEnums.MapLayer:
	set(v):
		map_layer = v
		match map_layer:
			DFServerEnums.MapLayer.LAYER_SEA:
				_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
			_:
				_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_AT_LEAST_ONE_WALKABLE
		_astar.update()

var region: Rect2i:
	set(v):
		_astar.region = region
		_astar.update()


var _astar: AStarGrid2D = AStarGrid2D.new()


func set_point_solid(v: Vector2i, solid: bool):
	_astar.set_point_solid(v, solid)


func execute(src: Vector2i, dst: Vector2i) -> Array[Vector2i]:
	return _astar.get_id_path(src, dst, true)
