class_name DFTileMapLayer
extends Node

# Convenience lookup modules
@onready var pathfinder: DFPathfinder = $Pathfinder

@export var region: Rect2i:
	set(v):
		region = v
		if pathfinder != null:
			pathfinder.region = v

@export var map_layer: DFServerEnums.MapLayer:
	set(v):
		map_layer = v
		for obstacle_layer in _obstacle_layer_lookup:
			_obstacle_layer_lookup[obstacle_layer].map_layer = v
		if pathfinder != null:
			pathfinder.map_layer = v


@onready var _obstacle_layer_lookup: Dictionary[DFServerEnums.ObstacleType, DFTileMapObstacleLayer] = {
	DFServerEnums.ObstacleType.OBSTACLE_TERRAIN:   $Terrain,
	DFServerEnums.ObstacleType.OBSTACLE_STRUCTURE: $Structure,
	DFServerEnums.ObstacleType.OBSTACLE_UNIT:      $Unit,
}


func get_occupied(v: Vector2i, obstacle_layer: DFServerEnums.ObstacleType) -> bool:
	if obstacle_layer not in _obstacle_layer_lookup:
		return false
	return _obstacle_layer_lookup[obstacle_layer].get_occupied(v)


func swap_state(
	v: Vector2i,
	src_obstacle_layer: DFServerEnums.ObstacleType,
	dst_obstacle_layer: DFServerEnums.ObstacleType,
) -> bool:
	if (
		(
			src_obstacle_layer != DFServerEnums.ObstacleType.OBSTACLE_NONE
		) != get_occupied(v, src_obstacle_layer)
	) or (
		(
			dst_obstacle_layer != DFServerEnums.ObstacleType.OBSTACLE_NONE
		) != get_occupied(v, dst_obstacle_layer)
	):
		return false
	
	var dst = not get_occupied(v, src_obstacle_layer)
	
	return (
		(
			src_obstacle_layer == DFServerEnums.ObstacleType.OBSTACLE_NONE
		) or (
			_obstacle_layer_lookup[src_obstacle_layer].swap_state(v, not dst)
		)
	) and (
		(
			dst_obstacle_layer == DFServerEnums.ObstacleType.OBSTACLE_NONE
		) or (
			_obstacle_layer_lookup[dst_obstacle_layer].swap_state(v, dst)
		)
	)


func _ready():
	for obstacle_layer in _obstacle_layer_lookup:
		_obstacle_layer_lookup[obstacle_layer].obstacle_layer = obstacle_layer
