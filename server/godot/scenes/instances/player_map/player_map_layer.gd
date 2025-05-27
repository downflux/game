@tool
class_name DFPlayerMapLayer
extends TileMapLayer

@export var map_layer: DFServerEnums.MapLayer:
	set(v):
		var p = get_parent()
		if p != null and p is DFPlayerMap:
			v = map_layer
		map_layer = v

const _OBSTACLE_LAYER: DFServerEnums.ObstacleType = DFServerEnums.ObstacleType.OBSTACLE_TERRAIN
const _TILESET_SOURCE_ID: int = 0

@onready var _atlas_coords: Vector2i = Vector2i(
	_OBSTACLE_LAYER - 1,
	map_layer - 1,
)

func get_occupied() -> Array[Vector2i]:
	return get_used_cells_by_id(_TILESET_SOURCE_ID, _atlas_coords)
