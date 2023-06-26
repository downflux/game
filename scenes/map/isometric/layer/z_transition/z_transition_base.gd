extends Area2D

class_name ZTransitionBase

@export var up_orientation: ZTransitionBase.Orientation

var _z_layer: int = -1

enum Orientation {
    ERROR_UNSPECIFIED,
    NORTH,
    NORTHEAST,
    EAST,
    SOUTHEAST,
    SOUTH,
    SOUTHWEST,
    WEST,
    NORTHWEST,
}

const _UP_VECTOR_LOOKUP: Dictionary = {
    Orientation.NORTH:     Vector2( 0, -1),
    Orientation.NORTHEAST: Vector2(-1, -1),
    Orientation.EAST:      Vector2(-1,  0),
    Orientation.SOUTHEAST: Vector2(-1,  1),
    Orientation.SOUTH:     Vector2( 0,  1),
    Orientation.SOUTHWEST: Vector2( 1,  1),
    Orientation.WEST:      Vector2( 1,  0),
    Orientation.NORTHWEST: Vector2( 1, -1),
}

class Plane2D:
    var p: Vector2
    var n: Vector2
    func _init(_p: Vector2, _n: Vector2):
        p = _p
        n = _n

# Planes here define the +z direction; the planes are defined in point-normal
# form, with the are in point-normal form, with the normal pointing into the +z
# direction.
#
# TODO(minkezhang): Detect the lower z-side instead.
var _UP_VECTOR_PLANE: Dictionary = {
    Orientation.NORTH:     Plane2D.new(Vector2(-32,   0), Vector2(-1,  2).normalized()),
    Orientation.NORTHEAST: Plane2D.new(Vector2(-32,   0), Vector2(-1,  0)),
    Orientation.EAST:      Plane2D.new(Vector2(  0, -16), Vector2(-1, -2).normalized()),
    Orientation.SOUTHEAST: Plane2D.new(Vector2(  0,  16), Vector2( 0, -1)),
    Orientation.SOUTH:     Plane2D.new(Vector2(  0, -16), Vector2( 1, -2).normalized()),
    Orientation.SOUTHWEST: Plane2D.new(Vector2( 32,   0), Vector2( 1,  0)),
    Orientation.WEST:      Plane2D.new(Vector2( 32,   0), Vector2( 1,  2).normalized()),
    Orientation.NORTHWEST: Plane2D.new(Vector2(-32,  16), Vector2( 0,  1)),
}

## _up defines the Cartesian direction which points towards the positive z-axis.
var _up: Vector2

func _ready():
    _up = _UP_VECTOR_LOOKUP[up_orientation].normalized()
    var parent = get_owner() as MapLayer
    if parent != null:
        _z_layer = parent.z_layer

# TODO(minkezhang): Check for z_layer offset.
func _body_is_above(body: DFUnit) -> bool:
    var p = DFVector.flatten(DFVector.inflate(global_position)) + _UP_VECTOR_LOOKUP[up_orientation] * 32
    var dp = body.df_unit.position2d() - p
    return dp.dot(_UP_VECTOR_LOOKUP[up_orientation]) > 0

# TODO(minkezhang): Emit signal to IsometricMap instead.
# TODO(minkezhang): Move children between MapLayers instead of worrying about z_index.
func _on_body_entered(body):
    if body is DFUnit:
        if _body_is_above(body):  # come down to current layer down (if tile is on next tile down)
            print(_body_is_above(body))
            (body as DFUnit).proxy_z_layer_down.emit(_z_layer)
        else:  # entering from bottom or side -- only increase Z-index
            pass

func _on_body_exited(body):
    if body is DFUnit:
        if _body_is_above(body):  # increase body z layer
            (body as DFUnit).proxy_z_layer_up.emit(_z_layer)
        else:  # exiting from bottom or side -- decrease Z-index
            pass
