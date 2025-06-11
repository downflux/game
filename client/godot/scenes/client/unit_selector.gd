class_name DFUnitSelector
extends Node2D

var _pan: bool


func get_pan() -> bool:
	return _pan


func set_pan(v: bool):
	if v:
		src = get_global_mouse_position()
		dst = get_global_mouse_position()
		visible = true
	_pan = v
	visible = v


var src: Vector2:
	set(v):
		src = v
		queue_redraw()

var dst: Vector2:
	set(v):
		dst = v
		queue_redraw()


func _draw():
	draw_line(src, Vector2(src.x, dst.y), Color.GREEN)
	draw_line(Vector2(src.x, dst.y), dst, Color.GREEN)
	draw_line(dst, Vector2(dst.x, src.y), Color.GREEN)
	draw_line(Vector2(dst.x, src.y), src, Color.GREEN)


func _process(_delta):
	if _pan:
		dst = get_global_mouse_position()


func _ready():
	visible = false
