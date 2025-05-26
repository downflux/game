@tool
class_name DFMap
extends Node2D
## Generates a server-side map for pathfinding.

@export var region: Rect2i

@onready var _map_layer_lookup: Dictionary[DFServerEnums.MapLayer, DFTileMapLayer] = {
	DFServerEnums.MapLayer.LAYER_AIR:    $Air,
	DFServerEnums.MapLayer.LAYER_GROUND: $Ground,
	DFServerEnums.MapLayer.LAYER_SEA:    $Sea,
}

var _occupied: Dictionary[DFServerEnums.MapLayer, Dictionary] = {}


func get_occupied() -> Dictionary[DFServerEnums.MapLayer, Dictionary]:
	return _occupied


## Update the runtime state-of-truth and set the cell [param v] of map layer
## [param layer] to the [param dst] type. In order to successfuly swap
## obstacle types, the caller must know the [param src] type of the cell; this
## is to prevent erroneously overwriting cells.
func swap_state(
	v: Vector2i,
	src_map_layer: DFServerEnums.MapLayer,
	dst_map_layer: DFServerEnums.MapLayer,
	src_obstacle_layer: DFServerEnums.ObstacleType,
	dst_obstacle_layer: DFServerEnums.ObstacleType,
	) -> bool:
	if (
		src_map_layer != DFServerEnums.MapLayer.LAYER_UNKNOWN
	) and (
		src_obstacle_layer != DFServerEnums.ObstacleType.OBSTACLE_NONE
	) and (
		v not in _occupied[src_map_layer][src_obstacle_layer]
	):
		return false
	if (
		dst_map_layer != DFServerEnums.MapLayer.LAYER_UNKNOWN
	) and (
		dst_obstacle_layer != DFServerEnums.ObstacleType.OBSTACLE_NONE
	) and (
		v in _occupied[dst_map_layer][dst_obstacle_layer]
	):
		return false
	
	# The respective DFTileMapLayer._occupied dicts are updated by calling each
	# layer's swap_state function, so there is no need to manually clear the dict
	# here in the calling function.
	return (
		(
			src_map_layer == DFServerEnums.MapLayer.LAYER_UNKNOWN
		) or (
			_map_layer_lookup[src_map_layer].swap_state(
				v,
				src_obstacle_layer,
				DFServerEnums.ObstacleType.OBSTACLE_NONE
			)
		)
	) and (
		(
			dst_map_layer == DFServerEnums.MapLayer.LAYER_UNKNOWN
		) or (
			_map_layer_lookup[dst_map_layer].swap_state(
				v,
				DFServerEnums.ObstacleType.OBSTACLE_NONE,
				dst_obstacle_layer,
			)
		)
	)


func _ready():
	if Engine.is_editor_hint():
		for map_layer in _map_layer_lookup.keys():
			_map_layer_lookup[map_layer].map_layer = map_layer
	if not Engine.is_editor_hint():
		for map_layer in _map_layer_lookup.keys():
			_occupied[map_layer] = _map_layer_lookup[map_layer].get_occupied()


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
