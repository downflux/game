class_name DFCurveBoolean
extends DFCurveBase

@export var data: Dictionary[int, bool] = {}
@export var default_value: bool = false


func get_value(timestamp: int) -> bool:
	return super.get_value(timestamp)
