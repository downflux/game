extends Resource

## DFUnit3D tracks the 3D coordinates for a unit.
##
## DFUnit3D frees the underlying (x, y, z) unit coordinates from the isometric
## rendering layer, which combines the y and z coordinates.
##
## The API for this unit should conform with that of CharacterBody3D where
## applicable.
class_name DFUnit3D

var position: Vector3
var velocity: Vector3

const _PIXELS_PER_LAYER = 32

# Corresponds to https://redd.it/mo9xyx
const _PIXELS_PER_METER = 100

func _init(p: Vector2 = Vector2(0, 0)):
    position = DFVector.inflate(p)

func position2d(mode: DFVector.Mode = DFVector.Mode.CARTESIAN) -> Vector2:
    return DFVector.flatten(position, mode)

func velocity2d(mode: DFVector.Mode = DFVector.Mode.CARTESIAN) -> Vector2:
    return DFVector.flatten(velocity, mode)

func z_layer() -> int:
    return floor(position.z / _PIXELS_PER_LAYER)

func _physics_process(_delta):
    position += velocity * _delta
