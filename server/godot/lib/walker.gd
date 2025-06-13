class_name DFServerComponentWalker
extends DFServerMoverBase

@export var speed: float
@export var position: DFCurveVector2
@export var map_layer: DFCurveMapLayer


func set_vector_path(timestamp: int, path: Array[Vector2i]):
	var t: int = position.get_window_end_timestamp(timestamp)
	if t == -1:
		t = timestamp
	
	var v: Vector2 = position.get_value(t)
	
	position.trim_keyframes(t, false)
	map_layer.trim_keyframes(t, false)
	
	for p in path:
		t += int(1000.0 * (1 / speed) * v.distance_to(p))
		position.add_keyframe(t, Vector2(p))
		map_layer.add_keyframe(t, DFEnums.MapLayer.LAYER_GROUND)
		v = p
