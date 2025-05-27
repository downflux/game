class_name DFMap
extends Node2D
## Generates a server-side map for pathfinding.

@export var region: Rect2i

@onready var _map_layer_lookup: Dictionary[DFServerEnums.MapLayer, DFTileMapLayer] = {
	DFServerEnums.MapLayer.LAYER_AIR:    $Air,
	DFServerEnums.MapLayer.LAYER_GROUND: $Ground,
	DFServerEnums.MapLayer.LAYER_SEA:    $Sea,
}


func get_occupied(
	v: Vector2i,
	map_layer: DFServerEnums.MapLayer,
	obstacle_layer: DFServerEnums.ObstacleType,
) -> bool:
	if map_layer not in _map_layer_lookup:
		return false
	return _map_layer_lookup[map_layer].get_occupied(v, obstacle_layer)


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
		(
			(
				src_map_layer != DFServerEnums.MapLayer.LAYER_UNKNOWN
			) and (
				src_obstacle_layer != DFServerEnums.ObstacleType.OBSTACLE_NONE
			) != (
				get_occupied(v, src_map_layer, src_obstacle_layer)
			)
		)
	) or (
		(
			(
				dst_map_layer != DFServerEnums.MapLayer.LAYER_UNKNOWN
			) and (
				dst_obstacle_layer != DFServerEnums.ObstacleType.OBSTACLE_NONE
			) != (
				get_occupied(v, dst_map_layer, dst_obstacle_layer)
			)
		)
	):
		return false
	
	
	return (
		(
			src_map_layer == DFServerEnums.MapLayer.LAYER_UNKNOWN
		) or (
			_map_layer_lookup[src_map_layer].swap_state(
				v,
				src_obstacle_layer,
				DFServerEnums.ObstacleType.OBSTACLE_NONE,
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
	for map_layer in _map_layer_lookup:
		_map_layer_lookup[map_layer].region = region
		_map_layer_lookup[map_layer].map_layer = map_layer
