# DFCurveBase is a partial class -- extensions must add the
#
#   data: Dictionary[int, Variant]
#   default_value: Variant
#
# properties. These properties may be definite types.
extends DFStateBase
class_name DFCurveBase

enum Type {
	TYPE_LINEAR,
	# TODO(minkezhang): Implement TYPE_PULSE, a STEP curve where each pulse spans
	# some window.
	TYPE_STEP,
}

@export var curve_type: Type
@export var timestamps: Array[int] = []


func remove_data(ts: Array[int]):
	is_dirty = true
	for t in ts:
		var i = timestamps.find(t)
		if i != -1:
			timestamps.remove_at(i)
			self.data.erase(i)


func add_data(data: Dictionary[int, Variant]):
	is_dirty = true
	for t in data:
		var i = timestamps.find(t)
		if i == -1:
			timestamps.append(t)
		data[t] = data[t]
	timestamps.sort()


func _get_value_step(timestamp: int) -> Variant:
	if not timestamps:
		return self.default_value
	
	var i = timestamps.find_custom(func(t): return t > timestamp)
	if i <= 0:
		return self.data[timestamps[i]]
	
	return self.data[timestamps[i - 1]]


func _get_value_linear(timestamp: int) -> Variant:
	if not timestamps:
		return self.default_value
	
	var i = timestamps.find_custom(func(t): return t > timestamp)
	
	if i <= 0:
		return self.data[timestamps[i]]
	
	return self.data[timestamps[i - 1]] + (
		self.data[timestamps[i]] - self.data[timestamps[i - 1]]
	) / (
		timestamps[i] - timestamps[i - 1]
	)


# Calculates and returns the interpolated value of the curve.
func get_value(timestamp: int) -> Variant:
	var v = null
	match curve_type:
		DFCurveBase.Type.TYPE_LINEAR:
			v = _get_value_linear(timestamp)
		DFCurveBase.Type.TYPE_STEP:
			v = _get_value_step(timestamp)
	return v if v != null else self.default_value


func to_dict(
	_sid: int,
	_full: bool,
	_query: Dictionary
) -> Dictionary:
	if not _full and not is_dirty:
		return {}
	return {
		DFStateKeys.KDFCurveType: curve_type,
		DFStateKeys.KDFCurveTimestamps: timestamps,
		DFStateKeys.KDFCurveData: self.data,
		DFStateKeys.KDFCurveDefaultValue: self.default_value,
	}
