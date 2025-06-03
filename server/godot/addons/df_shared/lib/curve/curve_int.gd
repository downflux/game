class_name DFCurveInt
extends DFCurveBase

@export var data: Dictionary[int, int] = {}
@export var default_value: int = 0


func get_value(timestamp: int) -> int:
	return super.get_value(timestamp)
