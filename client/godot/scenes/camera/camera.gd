class_name DFClientCamera
extends Camera2D

var _pan: bool = false


func set_pan(v: bool): 
	if v:
		_pan_origin = get_local_mouse_position()
	else:
		_velocity = 0
	_pan = v

var _pan_origin: Vector2
var _velocity: float
var _pan_direction: Vector2
const _VELOCITY_SCALE: float = 0.05


func _zoom(delta: Vector2):
	var pos: Vector2 = get_global_mouse_position()
	set_zoom((get_zoom() + delta).clamp(Vector2(1, 1), Vector2(10, 10)))
	position += pos - get_global_mouse_position()


func _process(delta):
	if _pan:
		position += _pan_direction * (_velocity * delta)


func _input(event: InputEvent):
	if event is InputEventMouseMotion and _pan:
		_pan_direction = get_local_mouse_position() - _pan_origin
		_velocity = clampf(
			_pan_direction.length() * get_zoom().length() * _VELOCITY_SCALE,
			1,
			10,
		)
	
	# Control zoom behavior.
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.is_pressed():
		_zoom(-Vector2(1, 1))
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP and event.is_pressed():
		_zoom(Vector2(1, 1))
