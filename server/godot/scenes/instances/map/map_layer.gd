class_name DFMapLayer
extends TileMapLayer


enum MapLayer {
	LAYER_NONE = 0,
	
	LAYER_AIR    = 1 << 1,
	LAYER_GROUND = 1 << 2,
	LAYER_SEA    = 1 << 3,
	
	LAYER_AMPHIBIOUS = LAYER_GROUND | LAYER_SEA,
}


@export var region: Rect2i
@export var layer: MapLayer

@onready var astar_grid: AStarGrid2D = _generate_astar_grid()


func _generate_astar_grid() -> AStarGrid2D:
	var g = AStarGrid2D.new()
	g.set_cell_shape(AStarGrid2D.CELL_SHAPE_SQUARE)
	g.set_cell_size(Vector2(1, 1))
	g.set_region(region)
	if layer & MapLayer.LAYER_SEA:
		g.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	else:
		g.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_AT_LEAST_ONE_WALKABLE
	return
