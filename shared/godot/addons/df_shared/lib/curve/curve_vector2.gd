class_name DFCurveVector2
extends DFCurveBase

@export var data: Dictionary[int, Vector2] = {}
@export var default_value: Vector2 = Vector2(0, 0)


func get_value(timestamp: int) -> Vector2:
	return super.get_value(timestamp)


func flatten(v: Vector2) -> float:
	return v.length()
