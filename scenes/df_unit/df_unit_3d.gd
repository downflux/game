extends Resource

## DFUnit3D tracks the 3D coordinates for a unit.
##
## DFUnit3D frees the underlying (x, y, z) unit coordinates from the isometric
## rendering layer, which combines the y and z coordinates.
##
## The API for this unit should conform with that of CharacterBody3D where
## applicable.
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
const _PIXELS_PER_LAYER = 32

# Corresponds to https://redd.it/mo9xyx
const _PIXELS_PER_METER = 100

func _init(position2d: Vector2 = Vector2(0, 0)):
    var p = _ISOMETRIC_TRANSFORM.affine_inverse() * position2d
    position.x = p.x
    position.y = p.y

func position2d(mode: ProjectionMode = ProjectionMode.CARTESIAN) -> Vector2:
    if mode == ProjectionMode.CARTESIAN:
        return Vector2(position.x, position.y)
    return _ISOMETRIC_TRANSFORM * Vector2(position.x, position.y) + Vector2(0, position.z)

func velocity2d(mode: ProjectionMode = ProjectionMode.CARTESIAN) -> Vector2:
    if mode == ProjectionMode.CARTESIAN:
        return Vector2(velocity.x, velocity.y)
    return _ISOMETRIC_TRANSFORM * Vector2(velocity.x, velocity.y) + Vector2(0, velocity.z)

func z_layer() -> int:
    return floor(position.z / _PIXELS_PER_LAYER)

func _physics_process(_delta):
    position += velocity * _delta
