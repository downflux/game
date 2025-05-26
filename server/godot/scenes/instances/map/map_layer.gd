@tool
class_name DFTileMapLayer
extends Node

@export var map_layer: DFServerEnums.MapLayer:
	set(v):
		if Engine.is_editor_hint():
			var p = get_parent()
			if p != null and p is DFMap:
				v = map_layer
		map_layer = v
		for obstacle_layer in _obstacle_layer_lookup.keys():
			_obstacle_layer_lookup[obstacle_layer].map_layer = map_layer


@onready var _obstacle_layer_lookup: Dictionary[DFServerEnums.ObstacleType, DFTileMapObstacleLayer] = {
	DFServerEnums.ObstacleType.OBSTACLE_TERRAIN:   $Terrain,
	DFServerEnums.ObstacleType.OBSTACLE_STRUCTURE: $Structure,
	DFServerEnums.ObstacleType.OBSTACLE_UNIT:      $Unit,
}

var _occupied: Dictionary = {} as Dictionary[DFServerEnums.ObstacleType, Dictionary]


func get_occupied() -> Dictionary[DFServerEnums.ObstacleType, Dictionary]:
	return _occupied as Dictionary[DFServerEnums.ObstacleType, Dictionary]


func swap_state(
	v: Vector2i,
	src_obstacle_layer: DFServerEnums.ObstacleType,
	dst_obstacle_layer: DFServerEnums.ObstacleType,
) -> bool:
	if (
		src_obstacle_layer != DFServerEnums.ObstacleType.OBSTACLE_NONE
	) and (
		v not in _occupied[src_obstacle_layer]
	):
		return false
	if (
		dst_obstacle_layer != DFServerEnums.ObstacleType.OBSTACLE_NONE
	) and (
		v in _occupied[dst_obstacle_layer]
	):
		return false
	
	if src_obstacle_layer != DFServerEnums.ObstacleType.OBSTACLE_NONE:
		_occupied[src_obstacle_layer].erase(v)
		_obstacle_layer_lookup[src_obstacle_layer].set_occupied(v, true)
	
	if dst_obstacle_layer != DFServerEnums.ObstacleType.OBSTACLE_NONE:
		_occupied[dst_obstacle_layer][v] = true
		_obstacle_layer_lookup[dst_obstacle_layer].set_occupied(
			v,
			dst_obstacle_layer == DFServerEnums.ObstacleType.OBSTACLE_NONE)
	
	return true


func _ready():
	if Engine.is_editor_hint():
		for obstacle_layer in _obstacle_layer_lookup.keys():
			_obstacle_layer_lookup[obstacle_layer].obstacle_layer = obstacle_layer
	if not Engine.is_editor_hint():
		for obstacle_layer in _obstacle_layer_lookup.keys():
			_occupied[obstacle_layer] = _obstacle_layer_lookup[obstacle_layer].get_occupied()
