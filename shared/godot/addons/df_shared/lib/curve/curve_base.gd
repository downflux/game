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

@export var _export_history_limit: int = DFSettings.CURVE_EXPORT_HISTORY_LIMIT
@export var _history_limit: int        = DFSettings.CURVE_HISTORY_LIMIT

## The type of interpolation for this curve.
@export var curve_type: Type

## A list of keyframe timestamps. Timestamps are non-negative integers.
@export var timestamps_msec: Array[int] = []


## Remove the keyframe at time [param t]. 
func erase_keyframe(t: int) -> void:
	if t not in self.data:
		return
	
	is_dirty = true
	var i = timestamps_msec.bsearch(t)
	timestamps_msec.remove_at(timestamps_msec.bsearch(t))
	self.data.erase(t)


## Truncates all keyframes before or after the window containing [param t].
func trim_keyframes(t: int, before: bool):
	if before:
		var i = _get_window_start_timestamp_index(t)
		if i > -1:
			is_dirty = true
			for j in range(0, i + 1):
				self.data.erase(timestamps_msec[j])
			timestamps_msec.reverse()
			timestamps_msec.resize(len(timestamps_msec) - (i + 1))
			timestamps_msec.reverse()
	else:
		var i = _get_window_end_timestamp_index(t)
		if t in self.data:
			i += 1
		if i == len(timestamps_msec):
			i = -1
		if i > -1:
			is_dirty = true
			for j in range(i, len(timestamps_msec)):
				self.data.erase(timestamps_msec[j])
			timestamps_msec.resize(i)


## Add keyframe at timestamp [param t]. 
func add_keyframe(t: int, v: Variant) -> void:
	is_dirty = true
	
	if t not in self.data:
		var i = timestamps_msec.bsearch(t)
		timestamps_msec.insert(i, t)
	
	self.data[t] = v


func _get_value_step(t: int) -> Variant:
	if t in self.data:
		return self.data[t]
	
	var i: int = _get_window_start_timestamp_index(t)
	if i == -1:
		return self.default_value
	
	return self.data[timestamps_msec[i]]


func _get_value_linear(t: int) -> Variant:
	if t in self.data:
		return self.data[t]
	
	var i = _get_window_start_timestamp_index(t)
	if i == -1:
		return self.default_value
	
	var j = _get_window_end_timestamp_index(t)
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


## Get the index of the next keyframe which contains the timestamp [param t].
## [br][br]
## A window is defined as [code](i - 1, i][/code], where [code]i[/code] is the
## keyframe index. Note that the interval is half-closed; if [param t] falls on
## a keyframe, we return the index of that keyframe. Returns [code]-1[/code] if
## [param t] is at or past the last keyframe.
func _get_window_end_timestamp_index(t: int) -> int:
	var i: int = timestamps_msec.bsearch(t, true)
	return i if i < len(timestamps_msec) else -1


func get_window_end_timestamp(t: int) -> int:
	var i: int = _get_window_end_timestamp_index(t)
	return timestamps_msec[i] if i != -1 else -1


## Get the index of the previous keyframe which contains the timestamp
## [param t].
func _get_window_start_timestamp_index(t: int) -> int:
	var i: int = _get_window_end_timestamp_index(t)
	return i - 1 if i != -1 else len(timestamps_msec) - 1


func get_window_start_timestamp(t: int) -> int:
	var i: int = _get_window_start_timestamp_index(t)
	return timestamps_msec[i] if i != -1 else -1


## Get the index of the next keyframe in the open interval [code](t, ∞)[/code].
## Return [code]-1[/code] if [param t] lies past the last keyframe.
func _get_next_timestamp_index(t: int) -> int:
	if t == -1:
		return t
	
	var i: int = timestamps_msec.bsearch(t, false)
	return i if i < len(timestamps_msec) else -1


func get_next_timestamp(t: int) -> int:
	if t == -1:
		return t
	
	var i: int = _get_next_timestamp_index(t)
	return timestamps_msec[i] if i != -1 else -1


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
	
	var ks: Array[int] = timestamps_msec
	var vs: Dictionary = self.data

	if _export_history_limit and len(ks) > _export_history_limit:
		ks = ks.slice(len(ks) - _export_history_limit)
		vs = {}
		for t in ks:
			vs[t] = self.data[t]
	
	data.merge({
		DFStateKeys.KDFCurveTimestampMSec: ks,
		DFStateKeys.KDFCurveData: vs,
	})
	
	return data


func from_dict(partial: bool, data: Dictionary):
	if DFStateKeys.KDFCurveType in data and not partial:
		curve_type = data[DFStateKeys.KDFCurveType]
	if DFStateKeys.KDFCurveDefaultValue in data and not partial:
		self.default_value = data[DFStateKeys.KDFCurveDefaultValue]
	
	# When merging timestamps, we replace the tail of the current keyframes
	# with incoming data.
	if DFStateKeys.KDFCurveTimestampMSec in data:
		if partial:
			var ts = data[DFStateKeys.KDFCurveTimestampMSec]
			if ts:
				# Truncate all future points in local state.
				trim_keyframes(get_window_start_timestamp(ts[0]), false)
				
				timestamps_msec.append_array(ts)
		else:
			timestamps_msec = data.get(DFStateKeys.KDFCurveTimestampMSec, [])
	
	if DFStateKeys.KDFCurveData in data:
		if partial:
			self.data.merge(data.get(DFStateKeys.KDFCurveData, {}))
		else:
			self.data = data.get(DFStateKeys.KDFCurveData, {})


func _gc():
	if len(timestamps_msec) < _history_limit:
		return
	
	timestamps_msec.reverse()
	var tail: Array[int] = timestamps_msec.slice(_history_limit)
	for t in tail:
		self.data.erase(t)
	timestamps_msec.resize(_history_limit)
	timestamps_msec.reverse()


func _physics_process(_delta):
	if _history_limit and len(timestamps_msec) > 1.5 * _history_limit:
		_gc()
