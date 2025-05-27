class_name DFTileMapObstacleLayer
extends TileMapLayer
## Defines an obstacle layer for a map at run-time.

@export var map_layer: DFServerEnums.MapLayer
@export var obstacle_layer: DFServerEnums.ObstacleType

const _TILESET_SOURCE_ID: int = 0

@onready var _atlas_coords: Vector2i = Vector2i(obstacle_layer - 1, map_layer - 1)

var _occupied: Dictionary = {} as Dictionary[Vector2i, bool]


func swap_state(v: Vector2i, src: bool) -> bool:
	if src != get_occupied(v):
		return false
	
	var dst = not src
	
	if not dst:  # Clear the bit.
		if v in _occupied:
			_occupied.erase(v)
	else:
		_occupied[v] = dst
	_swap_state_tile_map_layer(v, src)
	return true


## Sets a cell to the [DFTileMapObstacleLayer] [member obstacle_layer] value.
## [br][br]
## Note that this function does not do any error-checking and blindly
## overwrites the underlying cell.
func _swap_state_tile_map_layer(v: Vector2i, src: bool):
	var dst = not src
	if not dst:
		erase_cell(v)
	else:
		set_cell(
			v,
			_TILESET_SOURCE_ID,
			_atlas_coords,
		)


func get_occupied(v: Vector2i) -> bool:
	return _occupied.get(v, false)
