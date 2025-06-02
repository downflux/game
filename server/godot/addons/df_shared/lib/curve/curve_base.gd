class_name DFCurveBase
extends DFStateBase
## Partial class describing an interpolated property as a function of time.
## [br][br]
## Final classes of type [code]T[/code] must include the properties
## [codeblock]
## data: Dictionary[int, T]
## default_value: T
## [/codeblock]
## [br][br]
## See [DFCurveFloat] for a concrete example.

## Defines the type of interpolation for this curve.
## [br][br]
## TODO(minkezhang): Implement [code]TYPE_PULSE[/code], a step curve where each
## pulse spans some window.
enum Type {
	## The value [code]v(t)[/code] between two keyframes is a linear interpolation
	## of the two end values.
	TYPE_LINEAR,
	
	## The value [code]v(t)[/code] between two keyframes takes the value of the
	## previous keyframe.
	TYPE_STEP,
}

## The type of interpolation for this curve.
@export var curve_type: Type

## A list of keyframe timestamps. These timestamps are of the same scale as
## [member DFState.timestamp_msec]
@export var timestamps_msec: Array[int] = []


## Remove the input keyframes with time [code]timestamps_msec[/code] and
## associated data. 
func remove_data(ts: Array[int]) -> void:
	is_dirty = true
	for t in ts:
		var i = timestamps_msec.find(t)
		if i != -1:
			timestamps_msec.remove_at(i)
			self.data.erase(i)

## Add keyframes with time [code]timestamps_msec[/code] and associated data. 
func add_data(data: Dictionary[int, Variant]) -> void:
	is_dirty = true
	for t in data:
		var i = timestamps_msec.find(t)
		if i == -1:
			timestamps_msec.append(t)
		data[t] = data[t]
	timestamps_msec.sort()


func _get_value_step(t: int) -> Variant:
	if not timestamps_msec:
		return self.default_value
	
	var i = timestamps_msec.find_custom(func(u: int) -> bool: return u > t)
	if i <= 0:
		return self.data[timestamps_msec[i]]
	
	return self.data[timestamps_msec[i - 1]]


func _get_value_linear(t: int) -> Variant:
	if not timestamps_msec:
		return self.default_value
	
	var i = timestamps_msec.find_custom(func(u: int) -> bool: return u > t)
	
	if i <= 0:
		return self.data[timestamps_msec[i]]
	
	return self.data[timestamps_msec[i - 1]] + (
		self.data[timestamps_msec[i]] - self.data[timestamps_msec[i - 1]]
	) / (
		timestamps_msec[i] - timestamps_msec[i - 1]
	)


## Calculates and returns the interpolated value of the curve.
func get_value(t: int) -> Variant:
	var v = null
	match curve_type:
		DFCurveBase.Type.TYPE_LINEAR:
			v = _get_value_linear(t)
		DFCurveBase.Type.TYPE_STEP:
			v = _get_value_step(t)
	return v if v != null else self.default_value


func to_dict(
	_sid: int,
	partial: bool,
	query: Dictionary
) -> Dictionary:
	if partial and not is_dirty:
		return {}
	
	var data: Dictionary = {}
	
	# Read-only properties do not change and do not need to be re-broadcasted.
	if query.get(DFStateKeys.KDFCurveType, false) and not partial:
		data[DFStateKeys.KDFCurveType] = curve_type
	if query.get(DFStateKeys.KDFCurveDefaultValue, false) and not partial:
		data[DFStateKeys.KDFCurveDefaultValue] = self.default_value

	
	data.merge({
		DFStateKeys.KDFCurveTimestampMSec: timestamps_msec,
		DFStateKeys.KDFCurveData: self.data,
	})
	
	return data
