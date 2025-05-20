# This is a singleton module.
extends Node
class_name DFCurveUtils


static func remove_data(c: DFCurveBase, ts: Array[int]):
	for t in ts:
		var i = c.timestamps.find(t)
		if i != -1:
			c.timestamps.remove_at(i)
			c.data.erase(i)


static func add_data(c: DFCurveBase, data: Dictionary[int, Variant]):
	for t in data:
		var i = c.timestamps.find(t)
		if i == -1:
			c.timestamps.append(t)
		c.data[t] = data[t]
	c.timestamps.sort()


static func _get_value_step(c: DFCurveBase, timestamp: int) -> Variant:
	if not c.timestamps:
		return c.default_value
	
	var i = c.timestamps.find_custom(func(t): return t > timestamp)
	if i <= 0:
		return c.data[c.timestamps[i]]
	
	return c.data[c.timestamps[i - 1]]


static func _get_value_linear(c: DFCurveBase, timestamp: int) -> Variant:
	if not c.timestamps:
		return c.default_value
	
	var i = c.timestamps.find_custom(func(t): return t > timestamp)
	
	if i <= 0:
		return c.data[c.timestamps[i]]
	
	return c.data[c.timestamps[i - 1]] + (
		c.data[c.timestamps[i]] - c.data[c.timestamps[i - 1]]
	) / (
		c.timestamps[i] - c.timestamps[i - 1]
	)


# Calculates and returns the interpolated value of the curve.
static func get_value(c: DFCurveBase, timestamp: int) -> Variant:
	var v = null
	match c.curve_type:
		DFCurveBase.Type.TYPE_LINEAR:
			v = _get_value_linear(c, timestamp)
		DFCurveBase.Type.TYPE_STEP:
			v = _get_value_step(c, timestamp)
	return v if v != null else c.default_value
