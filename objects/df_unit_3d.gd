extends Resource

class_name DFUnit3D

enum ProjectionMode {
	CARTESIAN,
	ISOMETRIC,
}

var position: Vector3
var velocity: Vector3

var _ISOMETRIC_TRANSFORM = Transform2D(
	Vector2(0.5,  0.25),
	Vector2(0.5, -0.25),
	Vector2(0, 0)
)
const _LAYER_HEIGHT_PX = 32
const _PIXELS_PER_METER = 100

func position2d(mode: ProjectionMode = ProjectionMode.CARTESIAN) -> Vector2:
	if mode == ProjectionMode.CARTESIAN:
		return Vector2(position.x, position.y)
	return _ISOMETRIC_TRANSFORM * Vector2(position.x, position.y) + Vector2(0, position.z)

func velocity2d(mode: ProjectionMode = ProjectionMode.CARTESIAN) -> Vector2:
	if mode == ProjectionMode.CARTESIAN:
		return Vector2(velocity.x, velocity.y)
	return _ISOMETRIC_TRANSFORM * Vector2(velocity.x, velocity.y) + Vector2(0, velocity.z)

func z_layer() -> int:
	return floor(position.z / _LAYER_HEIGHT_PX)

func _physics_process(_delta):
	position += velocity * _delta * _PIXELS_PER_METER
