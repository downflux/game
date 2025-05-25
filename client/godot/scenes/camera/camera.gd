extends Camera2D

var _pan: bool = false
var _pan_origin: Vector2

func _zoom(delta: Vector2):
	var pos := get_global_mouse_position()
	set_zoom((get_zoom() + delta).clamp(Vector2(1, 1), Vector2(10, 10)))
	position += pos - get_global_mouse_position()


func _input(event: InputEvent):
	var e = make_input_local(event)

	# Drag viewport.
	#
	# See https://forum.godotengine.org/t/53630/4.
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_MIDDLE:
		if e.is_pressed():
			_pan = true
			_pan_origin = get_global_mouse_position()
		if e.is_released():
			_pan = false
	elif e is InputEventMouseMotion and _pan:
		var dv = _pan_origin - get_global_mouse_position()
		position += dv
	# Control zoom behavior.
	#
	elif e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_WHEEL_DOWN and e.is_pressed():
		_zoom(-Vector2(1, 1))
	elif e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_WHEEL_UP and e.is_pressed():
		_zoom(Vector2(1, 1))
