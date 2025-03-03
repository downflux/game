# DFNavigationUI overlays any UI elements for unit paths.
extends TileMapLayer
class_name DFNavigationUI


enum d {
	DIRECTION_UNKNOWN,
	DIRECTION_N,
	DIRECTION_NE,
	DIRECTION_E,
	DIRECTION_SE,
	DIRECTION_S,
	DIRECTION_SW,
	DIRECTION_W,
	DIRECTION_NW,
}

var _ATLAS_LOOKUP = {
	[d.DIRECTION_UNKNOWN, d.DIRECTION_UNKNOWN]: Vector2i(8, 8),
	
	[d.DIRECTION_UNKNOWN, d.DIRECTION_E]:  Vector2i(0, 9),
	[d.DIRECTION_UNKNOWN, d.DIRECTION_SE]: Vector2i(1, 9),
	[d.DIRECTION_UNKNOWN, d.DIRECTION_S]:  Vector2i(2, 9),
	[d.DIRECTION_UNKNOWN, d.DIRECTION_SW]: Vector2i(3, 9),
	[d.DIRECTION_UNKNOWN, d.DIRECTION_W]:  Vector2i(4, 9),
	[d.DIRECTION_UNKNOWN, d.DIRECTION_NW]: Vector2i(5, 9),
	[d.DIRECTION_UNKNOWN, d.DIRECTION_N]:  Vector2i(6, 9),
	[d.DIRECTION_UNKNOWN, d.DIRECTION_NE]: Vector2i(7, 9),
	
	[d.DIRECTION_E, d.DIRECTION_UNKNOWN]:  Vector2i(0, 8),
	[d.DIRECTION_SE, d.DIRECTION_UNKNOWN]: Vector2i(1, 8),
	[d.DIRECTION_S, d.DIRECTION_UNKNOWN]:  Vector2i(2, 8),
	[d.DIRECTION_SW, d.DIRECTION_UNKNOWN]: Vector2i(3, 8),
	[d.DIRECTION_W, d.DIRECTION_UNKNOWN]:  Vector2i(4, 8),
	[d.DIRECTION_NW, d.DIRECTION_UNKNOWN]: Vector2i(5, 8),
	[d.DIRECTION_N, d.DIRECTION_UNKNOWN]:  Vector2i(6, 8),
	[d.DIRECTION_NE, d.DIRECTION_UNKNOWN]: Vector2i(7, 8),
	
	[d.DIRECTION_NE, d.DIRECTION_W]:  Vector2i(0, 0),
	[d.DIRECTION_NE, d.DIRECTION_NW]: Vector2i(1, 0),
	[d.DIRECTION_NE, d.DIRECTION_N]:  Vector2i(2, 0),
	[d.DIRECTION_NE, d.DIRECTION_SE]: Vector2i(5, 0),
	[d.DIRECTION_NE, d.DIRECTION_S]:  Vector2i(6, 0),
	
	[d.DIRECTION_E, d.DIRECTION_W]:  Vector2i(0, 1),
	[d.DIRECTION_E, d.DIRECTION_NW]: Vector2i(1, 1),
	[d.DIRECTION_E, d.DIRECTION_N]:  Vector2i(2, 1),
	[d.DIRECTION_E, d.DIRECTION_NE]: Vector2i(3, 1),
	
	[d.DIRECTION_SE, d.DIRECTION_W]:  Vector2i(0, 2),
	[d.DIRECTION_SE, d.DIRECTION_NW]: Vector2i(1, 2),
	[d.DIRECTION_SE, d.DIRECTION_N]:  Vector2i(2, 2),
	[d.DIRECTION_SE, d.DIRECTION_NE]: Vector2i(3, 2),
	[d.DIRECTION_SE, d.DIRECTION_E]:  Vector2i(4, 2),
	
	[d.DIRECTION_S, d.DIRECTION_W]:  Vector2i(0, 3),
	[d.DIRECTION_S, d.DIRECTION_NW]: Vector2i(1, 3),
	[d.DIRECTION_S, d.DIRECTION_N]:  Vector2i(2, 3),
	[d.DIRECTION_S, d.DIRECTION_NE]: Vector2i(3, 3),
	[d.DIRECTION_S, d.DIRECTION_E]:  Vector2i(4, 3),
	[d.DIRECTION_S, d.DIRECTION_SE]: Vector2i(5, 3),
	
	[d.DIRECTION_SW, d.DIRECTION_W]:  Vector2i(0, 4),
	[d.DIRECTION_SW, d.DIRECTION_NW]: Vector2i(1, 4),
	[d.DIRECTION_SW, d.DIRECTION_N]:  Vector2i(2, 4),
	[d.DIRECTION_SW, d.DIRECTION_NE]: Vector2i(3, 4),
	[d.DIRECTION_SW, d.DIRECTION_E]:  Vector2i(4, 4),
	[d.DIRECTION_SW, d.DIRECTION_SE]: Vector2i(5, 4),
	[d.DIRECTION_SW, d.DIRECTION_S]:  Vector2i(6, 4),
	
	[d.DIRECTION_NW, d.DIRECTION_W]:  Vector2i(0, 6),
	[d.DIRECTION_NW, d.DIRECTION_NE]: Vector2i(3, 6),
	
	[d.DIRECTION_N, d.DIRECTION_W]:  Vector2i(0, 7),
	[d.DIRECTION_N, d.DIRECTION_NW]: Vector2i(1, 7),
	[d.DIRECTION_N, d.DIRECTION_NE]: Vector2i(3, 7),
}

# _get_direction gets the direction between two cells, calculated as the vector
# with tail at from and head at to.
#
# Example:
#   assert(
#     _get_direction(Vector2i(0, 0), Vector2i(1, 0)),
#     d.DIRECTION_EAST,
#   )
func _get_direction(src, dest: Vector2i) -> d:
	return {
		Vector2i(0, -1):  d.DIRECTION_N,  # Y-axis is inverted
		Vector2i(1, -1):  d.DIRECTION_NE,
		Vector2i(1, 0):   d.DIRECTION_E,
		Vector2i(1, 1):   d.DIRECTION_SE,
		Vector2i(0, 1):   d.DIRECTION_S,
		Vector2i(-1, 1):  d.DIRECTION_SW,
		Vector2i(-1, 0):  d.DIRECTION_W,
		Vector2i(-1, -1): d.DIRECTION_NW,
	}[dest - src]


func _get_atlas_tile(from, to: d):
	if not _ATLAS_LOOKUP.has([from, to]):
		return _ATLAS_LOOKUP[[to, from]]
	return _ATLAS_LOOKUP[[from, to]]


# show_path renders a given path using the UI arrows.
#
# Args:
#   path: list of Vector2i cells
func show_path(path: Array):
	clear()
	for i in len(path):
		var from: d = d.DIRECTION_UNKNOWN
		var to: d = d.DIRECTION_UNKNOWN
		if i > 0:
			from = _get_direction(path[i], path[i - 1])
		if i < len(path) - 1:
			to = _get_direction(path[i], path[i + 1])
		set_cell(
			path[i], get_tile_set().get_source_id(0), _get_atlas_tile(from, to),
		)
