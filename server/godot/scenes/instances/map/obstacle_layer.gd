class_name DFTileMapObstacleLayer
extends TileMapLayer
## Defines an obstacle layer for a map.
##
## This node will be used as a source of truth during import, but will then
## cede authority to [DFMap]. This node will be updated during runtime by
## [DFMap].


@export var map_layer: DFServerEnums.MapLayer
@export var obstacle_layer: DFServerEnums.ObstacleType

const _TILESET_SOURCE_ID: int = 0

@onready var _atlas_coords: Vector2i = Vector2i(obstacle_layer - 1, map_layer - 1)


func _validate() -> bool:
	return (
		map_layer not in DFServerEnums.UNIMPLEMENTED_MAP_LAYERS
	) and (
		obstacle_layer != DFServerEnums.ObstacleType.OBSTACLE_NONE
	)


func _ready():
	if not _validate():
		Logger.error("TileMapLayer is incorrectly configured")


## Sets a cell to the [DFTileMapObstacleLayer] [member obstacle_layer] value.
## [br][br]
## Note that this function does not do any error-checking and blindly
## overwrites the underlying cell.
func set_occupied(v: Vector2i, erase: bool):
	if erase:
		erase_cell(v)
	else:
		set_cell(
			v,
			_TILESET_SOURCE_ID,
			_atlas_coords,
		)


## Returns a list of all occupied cells for this node.
func get_occupied() -> Dictionary[Vector2i, bool]:
	var data = {} as Dictionary[Vector2i, bool]
	for v: Vector2i in get_used_cells_by_id(_TILESET_SOURCE_ID, _atlas_coords):
		data[v] = true
	return data
