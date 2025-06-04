class_name DFServerComponentWalker
extends Node

@export var speed: float
@export var x: DFCurveFloat
@export var y: DFCurveFloat
@export var map_layer: DFCurveMapLayer


func set_vector_path(timestamp: int, path: Array[Vector2i]):
	var t: int = x.get_next_timestamp(x.get_window_end_timestamp(timestamp))
	if t == -1:
		t = timestamp
	
	var v: Vector2 = Vector2(x.get_value(t), y.get_value(t))
	
	x.trim_keyframes(t, false)
	y.trim_keyframes(t, false)
	map_layer.trim_keyframes(t, false)
	
	for p in path:
		t += int(1000.0 * speed * v.distance_to(p))
		x.add_keyframe(t, p.x)
		y.add_keyframe(t, p.y)
		map_layer.add_keyframe(t, DFEnums.MapLayer.LAYER_GROUND)
		v = p
