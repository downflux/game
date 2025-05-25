class_name DFCurveBoolean
extends DFCurveBase

@export var data: Dictionary[int, bool] = {}
@export var default_value: bool = false


func add_data(d: Dictionary[int, bool]) -> void:
	super.add_data(d)


func get_value(timestamp: int) -> bool:
	return super.get_value(timestamp)
