class_name DFTileMapLayer
extends TileMapLayer
## Defines an obstacle layer for a map.
##
## This node will be used as a source of truth during import, but will then
## cede authority to [DFMap]. This node will be updated during runtime by
## [DFMap].


@export var map_layer: DFServerEnums.MapLayer

const _TILESET_SOURCE_ID: int = 0


func _get_atlas_coords(
	obstacle: DFServerEnums.ObstacleType,
) -> Vector2i:
	if obstacle == DFServerEnums.ObstacleType.OBSTACLE_NONE:
		return Vector2i(-1, -1)
	return Vector2i(obstacle - 1, map_layer)


func set_obstacle(obstacle: DFServerEnums.ObstacleType, v: Vector2i):
	if obstacle == DFServerEnums.ObstacleType.OBSTACLE_NONE:
		erase_cell(v)
	else:
		set_cell(
			v,
			_TILESET_SOURCE_ID,
			_get_atlas_coords(obstacle),
		)


func get_obstacles() -> Dictionary:
	var data: Dictionary = {}
	for obstacle: DFServerEnums.ObstacleType in DFServerEnums.ObstacleType.values():
		if obstacle == DFServerEnums.ObstacleType.OBSTACLE_NONE:
			continue
		data[obstacle] = get_used_cells_by_id(
			_TILESET_SOURCE_ID,
			_get_atlas_coords(obstacle)
		)
	return data
