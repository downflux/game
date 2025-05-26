class_name DFMap
extends Node2D
## Generates a server-side map for pathfinding.

@export var region: Rect2i

@onready var air: DFTileMapLayer    = $Air
@onready var ground: DFTileMapLayer = $Ground
@onready var sea: DFTileMapLayer    = $Sea

@onready var _layer_lookup: Dictionary[DFServerEnums.MapLayer, DFTileMapLayer] = {
	DFServerEnums.MapLayer.LAYER_AIR:    air,
	DFServerEnums.MapLayer.LAYER_GROUND: ground,
	DFServerEnums.MapLayer.LAYER_SEA:    sea,
}

var _occupied: Dictionary[DFServerEnums.MapLayer, Dictionary] = {
	DFServerEnums.MapLayer.LAYER_AIR:        {} as Dictionary[Vector2i, DFServerEnums.ObstacleType],
	DFServerEnums.MapLayer.LAYER_GROUND:     {} as Dictionary[Vector2i, DFServerEnums.ObstacleType],
	DFServerEnums.MapLayer.LAYER_SEA:        {} as Dictionary[Vector2i, DFServerEnums.ObstacleType],
}


## Update the runtime state-of-truth and set the cell [param v] of map layer
## [param layer] to the [param dst] type. In order to successfuly swap
## obstacle types, the caller must know the [param src] type of the cell; this
## is to prevent erroneously overwriting cells.
func swap_state(
	layer: DFServerEnums.MapLayer,
	v: Vector2i,
	src: DFServerEnums.ObstacleType,
	dst: DFServerEnums.ObstacleType,
	) -> bool:
	if layer not in _occupied:
		return false
	
	var g = _occupied[layer]
	if src != DFServerEnums.ObstacleType.OBSTACLE_NONE and ((
		v not in g
	) or (
		not src == g[v]
	)):
		return false
	
	g[v] = dst
	_layer_lookup[layer].set_obstacle(dst, v)
	
	return true


# Load initial map state to the runtime state-of-truth.
func _read_from_map_layers():
	for l in [air, ground, sea]:
		var data = l.get_obstacles()
		for obstacle: DFServerEnums.ObstacleType in data:
			for v: Vector2i in data[obstacle]:
				_occupied[l.map_layer][v] = obstacle


func _ready():
	_read_from_map_layers()
	
	swap_state(
		DFServerEnums.MapLayer.LAYER_GROUND,
		Vector2i(0, 6),
		DFServerEnums.ObstacleType.OBSTACLE_NONE,
		DFServerEnums.ObstacleType.OBSTACLE_TERRAIN,
	)
	swap_state(
		DFServerEnums.MapLayer.LAYER_SEA,
		Vector2i(0, 6),
		DFServerEnums.ObstacleType.OBSTACLE_NONE,
		DFServerEnums.ObstacleType.OBSTACLE_TERRAIN,
	)



"""
func _generate_astar_grid() -> AStarGrid2D:
	var g = AStarGrid2D.new()
	g.set_cell_shape(AStarGrid2D.CELL_SHAPE_SQUARE)
	g.set_cell_size(Vector2(1, 1))
	# g.set_region(region)
	if layer & MapLayer.LAYER_SEA:
		g.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	else:
		g.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_AT_LEAST_ONE_WALKABLE
	return
"""
