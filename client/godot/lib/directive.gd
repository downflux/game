class_name DFUnitDirective
extends Node2D

var _timer: Timer
const _wait_time_sec: int = 1

var src: Vector2:
	set(v):
		src = v
		queue_redraw()

var dst: Vector2:
	set(v):
		dst = v
		queue_redraw()


func start_timer():
	visible = true
	_timer.start(_wait_time_sec)


func _draw():
	draw_line(src, dst, Color.GREEN, -1, false)
	draw_polygon(
		PackedVector2Array([
			dst - Vector2(-1, -1),
			dst - Vector2(1, -1),
			dst - Vector2(1, 1),
			dst - Vector2(-1, 1),
		]),
		[ Color.GREEN ],
	)


func _process(_delta):
	visible = visible and (src - dst).length_squared() > 16


func _ready():
	visible = false
	
	_timer = Timer.new()
	_timer.timeout.connect(func(): visible = false)
	add_child(_timer)
