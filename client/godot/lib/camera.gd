class_name DFClientCamera
extends Camera2D

var _maybe_pan: bool = false
var _pan: bool       = false
var _pan_origin: Vector2
var _pan_direction: Vector2
var _velocity: float
const _VELOCITY_SCALE: float = 0.05


func get_pan() -> bool:
	return _pan


func set_pan(v: bool): 
	if v:
		_pan_origin = get_local_mouse_position()
	else:
		_maybe_pan = false
		_velocity = 0
	_pan = v


func _zoom(delta: Vector2):
	var pos: Vector2 = get_global_mouse_position()
	set_zoom((get_zoom() + delta).clamp(Vector2(1, 1), Vector2(10, 10)))
	position += pos - get_global_mouse_position()


func _process(delta):
	if _pan:
		position += _pan_direction * (_velocity * delta)


func _input(event: InputEvent):
	if event.is_action_pressed("camera_pan"):
		_maybe_pan = true
		get_viewport().set_input_as_handled()
	if event.is_action_released("camera_pan"):
		set_pan(false)
		get_viewport().set_input_as_handled()
	
	if event is InputEventMouseMotion and _maybe_pan:
		if not get_pan():
			set_pan(true)
		_pan_direction = get_local_mouse_position() - _pan_origin
		_velocity = clampf(
			_pan_direction.length() * get_zoom().length() * _VELOCITY_SCALE,
			1,
			10,
		)
		get_viewport().set_input_as_handled()
	
	# Control zoom behavior.
	if event.is_action_pressed("camera_zoom_in"):
		_zoom(-Vector2(1, 1))
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("camera_zoom_out"):
		_zoom(Vector2(1, 1))
		get_viewport().set_input_as_handled()
