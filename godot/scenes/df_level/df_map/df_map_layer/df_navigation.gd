extends Node
class_name DFNavigation


enum Layer {
	LAYER_UNKNOWN = 0,
	LAYER_GROUND = 1,
	LAYER_SEA = 2,
}


# _layers is a dictionary lookup of each pathfinding layer.
#
# The dictionary is keyed by the Layer enum.
var _layers = {
	Layer.LAYER_GROUND: _Pathfinder.new(),
	Layer.LAYER_SEA: _Pathfinder.new(),
	Layer.LAYER_GROUND | Layer.LAYER_SEA: _Pathfinder.new(),
}


func set_point_solid(layer: Layer, id: Vector2i, solid: bool):
	for l in _layers:
		if (layer & l == l) and _layers.has(l):
			_layers[l].set_point_solid(id, solid)


# fill_solid_region is used during run-time when buildings are added or
# destroyed.
#
# N.B.: The function caller is responsible for restoring the pathfinding grid
# to its original state if the region in question is not completely empty.
func fill_solid_region(layer: Layer, region: Rect2i, solid: bool):
	for l in _layers:
		if (layer & l == l) and _layers.has(l):
			_layers[l].fill_solid_region(region, solid)


# _bfs searches the associated map layer for the first matching, free cell.
#
# If there are multiple matching cells, _bfs will return the cell which
# minimizes the given heuristic h(id: Vector2i) -> float.
#
# If there is no open cell, _bfs returns original input cell.
func _bfs(layer: Layer, open_id: Vector2i, h: Callable) -> Vector2i:
	var open = [open_id]
	var candidate = open_id
	var success = false
	var offset = 0
	
	if not _layers.has(layer):
		return candidate
	
	while open.size() and not success:
		var cost = INF
		for c in open:
			if _layers[layer].is_in_boundsv(c) and (
				not _layers[layer].is_point_solid(c)
			):
				success = true
				var g = h.call(c)
				if g < cost:
					cost = g
					candidate = c
		
		# Generate adjacent cells.
		if not success:
			open = []
			offset += 1
			for dx in range(-offset, offset + 1):
				for dy in range(-offset, offset + 1):
					var dv = Vector2i(dx, dy)
					var c = open_id + dv
					if _layers[layer].is_in_boundsv(c):
						open.append(c)
			open.shuffle()
	
	return candidate

func get_id_path(
	layer: Layer,
	from_id: Vector2i,
	to_id: Vector2i,
	allow_partial_path: bool) -> Array:
	if not _layers.has(layer):
		return []
	
	# Select nearest free source cell in the current layer close to the from_id.
	var src_id = _bfs(
		layer,
		from_id,
		func(id: Vector2i) -> float: return (from_id - id).length_squared())
	
	# Select nearest free target cell in the current layer close to the from_id.
	# This cell is not guaranteed to be reachable (e.g. across a wall).
	var dest_id = _bfs(
		layer,
		to_id,
		func(id: Vector2i) -> float: return (from_id - id).length_squared())
	
	return _layers[layer].get_id_path(src_id, dest_id, allow_partial_path)

func set_region(region: Rect2i):
	for l in _layers:
		_layers[l].set_region(region)
		_layers[l].update()
		_layers[l].fill_solid_region(region, true)


class _Pathfinder extends AStarGrid2D:
	func _init():
		set_cell_shape(CellShape.CELL_SHAPE_ISOMETRIC_RIGHT)
		set_cell_size(Vector2i(32, 16))
		update()
		set_diagonal_mode(DiagonalMode.DIAGONAL_MODE_AT_LEAST_ONE_WALKABLE)
