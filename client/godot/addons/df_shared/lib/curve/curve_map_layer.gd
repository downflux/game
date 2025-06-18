class_name DFCurveMapLayer
extends DFCurveBase

@export var data: Dictionary[int, DFEnums.MapLayer] = {}
@export var default_value: DFEnums.MapLayer


func get_value(timestamp: int) -> DFEnums.MapLayer:
	return super.get_value(timestamp)


func flatten(v: DFEnums.MapLayer) -> float:
	return v
