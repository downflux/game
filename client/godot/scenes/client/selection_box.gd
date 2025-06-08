class_name DFSelectionBox
extends Node2D

var start: Vector2:
	set(v):
		start = v
		queue_redraw()

var end: Vector2:
	set(v):
		end = v
		queue_redraw()


func _draw():
	draw_line(start, Vector2(start.x, end.y), Color.GREEN)
	draw_line(Vector2(start.x, end.y), end, Color.GREEN)
	draw_line(end, Vector2(end.x, start.y), Color.GREEN)
	draw_line(Vector2(end.x, start.y), start, Color.GREEN)


func _ready():
	visible = false
