@tool

class_name DFCurveBaseDrawer
extends Node2D

@export var curve: DFCurveBase
@export var dimension: Rect2i:
	set(v):
		if Engine.is_editor_hint():
			queue_redraw()
		dimension = v


func _draw():
	draw_rect(dimension, Color.RED, false)
	
	if Engine.is_editor_hint():
		return
	
	var vmax: float = curve.flatten(curve.default_value)
	var vmin: float = vmax
	
	for t: int in curve.timestamps_msec:
		var v: float = curve.flatten(curve.get_value(t))
		vmax = max(vmax, v)
		vmin = min(vmin, v)
	
	var tmin: float = curve.timestamps_msec[0]
	var tmax: float = curve.timestamps_msec[-1]
	
	var w: float = float(dimension.size.x) / (tmax - tmin)
	var h: float = float(dimension.size.y) / (vmax - vmin)
	
	for i: int in len(curve.timestamps_msec) - 1:
		var t1 = curve.timestamps_msec[i]
		var t2 = curve.timestamps_msec[i + 1]
		var v1 = curve.flatten(curve.get_value(t1))
		var v2 = curve.flatten(curve.get_value(t2))
		
		var start: Vector2 = Vector2(
			(t1 - tmin) * w,
			(v1 - vmin) * h,
		)
		var end: Vector2 = Vector2(
			(t2 - tmin) * w,
			(v2 - vmin) * h,
		)
		
		draw_line(
			Vector2(dimension.position.x, 0) + Vector2(
				start.x,
				dimension.size.y - start.y,
			),
			Vector2(dimension.position.x, 0) + Vector2(
				end.x,
				dimension.size.y - end.y,
			),
			Color.GREEN,
			1,
		)


func _ready():
	if not Engine.is_editor_hint():
		curve.modified.connect(queue_redraw)
