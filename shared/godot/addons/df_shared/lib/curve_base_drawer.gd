@tool

class_name DFCurveBaseDrawer
extends Node2D

@export var is_realtime: bool
@export var max_timestamp_msec_window: int
@export var curve: DFCurveBase
@export var dimension: Rect2i:
	set(v):
		if Engine.is_editor_hint():
			queue_redraw()
		dimension = v


func _process(_delta):
	if is_realtime and not Engine.is_editor_hint():
		queue_redraw()


func _to_canvas(p: Vector2) -> Vector2:
	return Vector2(dimension.position) + Vector2(
		p.x,
		dimension.size.y - p.y,
	)


func _draw():
	draw_rect(dimension, Color.RED, false)
	
	if Engine.is_editor_hint():
		return
	
	if not curve.timestamps_msec:
		return
	
	var vmax: float = curve.flatten(curve.default_value)
	var vmin: float = vmax
	
	for t: int in curve.timestamps_msec:
		var v: float = curve.flatten(curve.get_value(t))
		vmax = max(vmax, v)
		vmin = min(vmin, v)
	
	var tmin: float = curve.timestamps_msec[0] if not is_realtime else (
		max(Time.get_ticks_msec() - max_timestamp_msec_window, 0) if max_timestamp_msec_window > 0 else 0
	)
	var tmax: float = curve.timestamps_msec[-1] if not is_realtime else Time.get_ticks_msec()
	var w: float = float(dimension.size.x) / (tmax - tmin)
	var h: float = float(dimension.size.y) / (vmax - vmin)
	
	var timestamps_msec: Array[float]
	if is_realtime:
		timestamps_msec = [tmin]
	timestamps_msec.append_array(curve.timestamps_msec)
	if is_realtime:
		timestamps_msec.append(tmax)
	
	for i: int in len(timestamps_msec) - 1:
		var t1 = timestamps_msec[i]
		var t2 = timestamps_msec[i + 1]
		
		if is_realtime:
			t1 = clamp(t1, tmin, tmax)
			t2 = clamp(t2, tmin, tmax)
		
		var v1 = curve.flatten(curve.get_value(t1))
		var v2 = curve.flatten(curve.get_value(t2))
		
		match curve.curve_type:
			DFCurveBase.Type.TYPE_STEP:
				var p1: Vector2 = Vector2(
					(t1 - tmin) * w,
					(v1 - vmin) * h,
				)
				var p3: Vector2 = Vector2(
					(t2 - tmin) * w,
					(v2 - vmin) * h,
				)
				var p2: Vector2 = Vector2(p3.x, p1.y)
				
				draw_line(_to_canvas(p1), _to_canvas(p2), Color.GREEN, 1)
				draw_line(_to_canvas(p2), _to_canvas(p3), Color.GREEN, 1)
				if t1 > tmin and t1 < tmax:
					_draw_indicator_line(_to_canvas(p1))
				if t2 > tmin and t2 < tmax:
					_draw_indicator_line(_to_canvas(p3))
			DFCurveBase.Type.TYPE_LINEAR:
				var start: Vector2 = Vector2(
					(t1 - tmin) * w,
					(v1 - vmin) * h,
				)
				var end: Vector2 = Vector2(
					(t2 - tmin) * w,
					(v2 - vmin) * h,
				)
				draw_line(_to_canvas(start), _to_canvas(end), Color.GREEN, 1)
				if t1 > tmin and t1 < tmax:
					_draw_indicator_line(_to_canvas(start))
				if t2 > tmin and t2 < tmax:
					_draw_indicator_line(_to_canvas(end))

func _draw_indicator_line(v: Vector2):
	draw_line(
			Vector2(
				v.x,
				clamp(
					v.y - 5,
					dimension.position.y,
					dimension.position.y + dimension.size.y,
				),
			),
			Vector2(
				v.x,
				clamp(
					v.y + 5,
					dimension.position.y,
					dimension.position.y + dimension.size.y,
				),
			),
			Color.RED,
	)


func _ready():
	if not Engine.is_editor_hint():
		curve.modified.connect(queue_redraw)
