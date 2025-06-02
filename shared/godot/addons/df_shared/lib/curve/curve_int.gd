class_name DFCurveInt
extends DFCurveBase

@export var data: Dictionary[int, int] = {}
@export var default_value: int = 0


func add_data(d: Dictionary[int, int]) -> void:
	super.add_data(d)


func get_value(timestamp: int) -> int:
	return super.get_value(timestamp)
