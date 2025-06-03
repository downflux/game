class_name DFCurveMapLayer
extends DFCurveBase

@export var data: Dictionary[int, DFEnums.MapLayer] = {}
@export var default_value: DFEnums.MapLayer


func add_data(d: Dictionary[int, DFEnums.MapLayer]) -> void:
	super.add_data(d)


func get_value(timestamp: int) -> DFEnums.MapLayer:
	return super.get_value(timestamp)
