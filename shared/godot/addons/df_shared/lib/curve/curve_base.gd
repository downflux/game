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
func erase_data(t: int) -> void:
	if t not in self.data:
		return
	
	is_dirty = true
	var i = timestamps_msec.bsearch(t)
	timestamps_msec.remove_at(timestamps_msec.bsearch(t))
	self.data.erase(t)


## Truncates all data before or after the given timestamp.
## [br][br]
## Data in the range [code](-∞, t)[/code] and [code](t, ∞)[/code] are deleted.
func trim_data(t: int, before: bool):
	if before:
		var i = get_prev_timestamp_index(t)
		if t in self.data:
			i -= 1
		if i > -1:
			is_dirty = true
			for j in range(0, i + 1):
				self.data.erase(timestamps_msec[j])
			timestamps_msec.reverse()
			timestamps_msec.resize(len(timestamps_msec) - (i + 1))
			timestamps_msec.reverse()
	else:
		var i = get_next_timestamp_index(t)
		if i > -1:
			is_dirty = true
			for j in range(i, len(timestamps_msec)):
				self.data.erase(timestamps_msec[j])
			timestamps_msec.resize(i)


## Add keyframes with time [code]timestamps_msec[/code] and associated data. 
func add_data(t: int, v: Variant) -> void:
	is_dirty = true
	
	if t not in self.data:
		var i = timestamps_msec.bsearch(t)
		timestamps_msec.insert(i, t)
	
	self.data[t] = v


func _get_value_step(t: int) -> Variant:
	if t in self.data:
		return self.data[t]
	
	var i: int = get_prev_timestamp_index(t)
	if i == -1:
		return self.default_value
	
	return self.data[timestamps_msec[i]]


func _get_value_linear(t: int) -> Variant:
	if t in self.data:
		return self.data[t]
	
	var i = get_prev_timestamp_index(t)
	
	if i == -1:
		return self.default_value
	
	var j = get_next_timestamp_index(t)
	
	if j == -1:
		return self.data[timestamps_msec[len(timestamps_msec) - 1]]
	
	return self.data[timestamps_msec[i]] + (
		self.data[timestamps_msec[j]] - self.data[timestamps_msec[i]]
	) / (
		timestamps_msec[j] - timestamps_msec[i]
	) * (
		t - timestamps_msec[i]
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


## Get the adjacent timestamp of the input [param t] which does not include
## [param t] itself.
func get_next_timestamp_index(t: int) -> int:
	var i: int = timestamps_msec.bsearch(t, false)
	return i if i < len(timestamps_msec) else -1


func get_prev_timestamp_index(t: int) -> int:
	var i: int = get_next_timestamp_index(t)
	return i - 1 if i != -1 else len(timestamps_msec) - 1


func to_dict(
	_sid: int,
	partial: bool,
	query: Dictionary
) -> Dictionary:
	if partial and not is_dirty:
		return {}
	
	var data: Dictionary = {}
	
	# Read-only properties do not change and do not need to be re-broadcasted.
	if not partial:
		data[DFStateKeys.KDFCurveType] = curve_type
	if not partial:
		data[DFStateKeys.KDFCurveDefaultValue] = self.default_value
	
	data.merge({
		DFStateKeys.KDFCurveTimestampMSec: timestamps_msec,
		DFStateKeys.KDFCurveData: self.data,
	})
	
	return data


func from_dict(partial: bool, data: Dictionary):
	if DFStateKeys.KDFCurveType in data and not partial:
		curve_type = data[DFStateKeys.KDFCurveType]
	if DFStateKeys.KDFCurveDefaultValue in data and not partial:
		self.default_value = data[DFStateKeys.KDFCurveDefaultValue]
	
	if DFStateKeys.KDFCurveTimestampMSec in data:
		if partial:
			var unique: Dictionary[int, bool] = {}
			timestamps_msec.append_array(data.get(DFStateKeys.KDFCurveTimestampMSec, []))
			for t in timestamps_msec:
				unique[t] = true
			timestamps_msec = unique.keys()
			timestamps_msec.sort()
		else:
			timestamps_msec = data.get(DFStateKeys.KDFCurveTimestampMSec, [])
	
	if DFStateKeys.KDFCurveData in data:
		if partial:
			self.data.merge(data.get(DFStateKeys.KDFCurveData, {}))
		else:
			self.data = data.get(DFStateKeys.KDFCurveData, {})
