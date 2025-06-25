class_name DFServerComponentWalker
extends DFServerMoverBase

@export var speed: float
@export var position: DFCurveVector2
@export var map_layer: DFCurveMapLayer


var _curr: Vector2i = Vector2i.MAX:
	set(v):
		curr_tile_changed.emit(_curr, v)
		_curr = v
var _next: Vector2i = Vector2i.MAX:
	set(v):
		next_tile_changed.emit(_next, v)
		_next = v


func _process(_delta):
	set_tiles(T.get_timestamp_msec(), T.DELTA_MSEC)


func set_tiles(timestamp_msec: int, delta_msec: int):
	var c: Vector2i  = position.get_value(timestamp_msec).snapped(Vector2i(1, 1))
	var dp: Vector2 = (
		position.get_value(timestamp_msec + delta_msec)
	) - (
		position.get_value(timestamp_msec)
	)
	var n: Vector2i  = _next
	# Signal if the upcoming movement increment will cross the current tile
	# boundary; after this move has occurred, clear destination node.
	if abs(dp.length_squared()) > 0.01:
		n = c + Vector2i((dp / dp.length()).snapped(Vector2i(1, 1)))
	else:
		n = Vector2i.MAX
	
	# Only update the next tile if the unit is moving away from the current tile.
	# If the unit is moving towards the current tile, it may stop immediately and
	# does not need to reserve the next tile in its estimated trajectory.
	if (
		(position.get_value(timestamp_msec) - Vector2(n)).length_squared()
	) > (
		(c - n).length_squared()
	):
		n = Vector2i.MAX
	
	if c != _curr:
		_curr = c
	if n != _next:
		_next = n


func set_vector_path(timestamp: int, path: Array[Vector2i]):
	if not path:
		return
	
	dst = path[-1]
	dst_layer = DFEnums.MapLayer.LAYER_GROUND
	
	var t: int = position.get_window_end_timestamp(timestamp)
	if t == -1:
		t = timestamp
	
	var v: Vector2 = position.get_value(t)
	
	position.trim_keyframes(t, false, true)
	map_layer.trim_keyframes(t, false, true)
	
	for i in range(len(path)):
		var p = path[i]
		t += int(1000.0 * (1 / speed) * v.distance_to(p))
		position.add_keyframe(t, Vector2(p))
		
		if i == len(path) - 1:
			map_layer.add_keyframe(t, DFEnums.MapLayer.LAYER_GROUND)
		
		v = p


func delay(timestamp: int):
	var t: int = position.get_window_start_timestamp(timestamp)
	if t == -1:
		t = timestamp
	
	position.trim_keyframes(timestamp, false, true)
	map_layer.trim_keyframes(timestamp, false, true)
	
	position.add_keyframe(timestamp, position.get_value(timestamp))
	map_layer.add_keyframe(timestamp, map_layer.get_value(timestamp))
