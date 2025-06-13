class_name DFServerComponentWalker
extends DFServerMoverBase

@export var speed: float
@export var position: DFCurveVector2
@export var map_layer: DFCurveMapLayer


var curr: Vector2i
var next: Vector2i


func set_tiles(timestamp: int):
	var t: Vector2 = position.get_value(timestamp)
	var dt: Vector2 = Vector2(t - round(t))
	var c: Vector2i = Vector2i(t)
	var n: Vector2i
	if abs(dt.length_squared()) > 0.01:
		n = Vector2(c) + dt / dt.length()
	if c != curr:
		tile_changed.emit(curr, c)
		curr = c
	if n != next:
		tile_changed.emit(next, n)
		next = n


func set_vector_path(timestamp: int, path: Array[Vector2i]):
	var t: int = position.get_window_end_timestamp(timestamp)
	if t == -1:
		t = timestamp
	
	var v: Vector2 = position.get_value(t)
	
	position.trim_keyframes(t, false)
	map_layer.trim_keyframes(t, false)
	
	for i in range(len(path)):
		var p = path[i]
		t += int(1000.0 * (1 / speed) * v.distance_to(p))
		position.add_keyframe(t, Vector2(p))
		
		if i == len(path) - 1:
			map_layer.add_keyframe(t, DFEnums.MapLayer.LAYER_GROUND)
		
		v = p
