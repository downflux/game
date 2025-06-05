class_name DFUnitDirective
extends Line2D

var src: Vector2:
	set(v):
		src = v
		redraw()

var dst: Vector2:
	set(v):
		dst = v
		redraw()


func redraw():
	visible = (src - dst).length_squared() < 1e-3
	clear_points()
	add_point(src)
	add_point(dst)
