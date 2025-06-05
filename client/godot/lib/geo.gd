class_name DFGeo
extends Node

static var _offset: Vector2 = DFClientSettings.GRID_CELL_SIZE / 2


static func to_local(g: Vector2) -> Vector2:
	return Vector2(
		_offset.x * (g.y + g.x) + _offset.x,
		_offset.y * (g.y - g.x) + _offset.y,
	)


static func to_grid(w: Vector2) -> Vector2i:
	return Vector2i(
		round((w.x - 2 * w.y) / DFClientSettings.GRID_CELL_SIZE.x),
		round((w.x + 2 * w.y - DFClientSettings.GRID_CELL_SIZE.x) / DFClientSettings.GRID_CELL_SIZE.x),
	)
