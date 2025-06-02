class_name DFCurveFloat
extends DFCurveBase

@export var data: Dictionary[int, float] = {}
@export var default_value: float = 0


func add_data(d: Dictionary[int, float]) -> void:
	super.add_data(d)


func get_value(timestamp: int) -> float:
	return super.get_value(timestamp)
