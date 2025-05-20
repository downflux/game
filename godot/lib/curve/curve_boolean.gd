extends DFCurveBase
class_name DFCurveBoolean

@export var data: Dictionary[int, bool] = {}
@export var default_value: bool = false

func add_data(d: Dictionary[int, bool]):
	super.add_data(d)

func get_value(timestamp: int) -> bool:
	return super.get_value(timestamp)
