class_name DFServerComponentWalker
extends Node

@export var speed: float
@export var x: DFCurveFloat
@export var y: DFCurveFloat
@export var map_layer: DFCurveMapLayer


func set_vector_path(timestamp: int, path: Array[Vector2i]):
	var t: int = x.get_adjacent_timestamp(timestamp, true)
	var v: Vector2 = Vector2(x.get_value(t), y.get_value(t))
	
	x.truncate_data(timestamp, true)
	y.truncate_data(timestamp, true)
	map_layer.truncate_data(timestamp, true)
	
	for p in path:
		t += int(1000.0 * speed * v.distance_to(p))
		x.add_data(t, p.x)
		y.add_data(t, p.y)
		v = p
