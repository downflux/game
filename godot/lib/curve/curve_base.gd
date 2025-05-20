extends Node
class_name DFCurveBase

enum Type {
	TYPE_LINEAR,
	# TYPE_PULSE,  # PULSE is STEP with width of window.
	TYPE_STEP,
}

@export var curve_type: Type
@export var timestamps: Array[int] = []


func to_dict(_permission: DFEnums.Permission) -> Dictionary:
	return {
		DFStateKeys.CurveType: curve_type,
		DFStateKeys.Timestamps: timestamps,
		DFStateKeys.Data: self.data,
		DFStateKeys.DefaultValue: self.default_value,
	}
