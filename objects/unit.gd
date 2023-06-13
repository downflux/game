extends CharacterBody2D

class_name Unit

var _ISOMETRIC_TRANSFORM = Transform2D(
	Vector2(0.5, -0.25),
	Vector2(0.5,  0.25),
	Vector2.ZERO,
)
const _EPSILON = 1e-2

var _body: CharacterBody2D

var _position3: Vector3
var _position3_buf: Vector3

func position3() -> Vector3:
	return Vector3(_position3)

func set_position3(p: Vector3):
	_position3.x = p.x
	_position3.y = p.y
	_position3.z = p.z

func velocity3() -> Vector3:
	var v = _position3 - _position3_buf
	return v if v.length_squared() > _EPSILON else Vector3.ZERO 

func _process(_delta):
	_position3_buf.x = _position3.x
	_position3_buf.y = _position3.y
	_position3_buf.z = _position3.z
	position = (
		_ISOMETRIC_TRANSFORM * Vector2(_position3.x, _position3.y)
	) + Vector2(0, _position3.z)

func _physics_process(_delta):
	_body.move_and_slide()
