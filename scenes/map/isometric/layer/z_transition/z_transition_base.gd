extends Area2D

class_name ZTransitionBase

@export var up_orientation: ZTransitionBase.Orientation
@export var up_line: Line2D = null

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

# Planes here define the +z direction; the planes are defined in point-normal
# form, with the are in point-normal form, with the normal pointing into the +z
# direction.
var _UP_VECTOR_PLANE: Dictionary = {
    Orientation.NORTH: {
        "P": Vector2(-32, 0),
        "N": Vector2(-1,  2).normalized(),
    },
    Orientation.SOUTH: {
        "P": Vector2(0, -16),
        "N": Vector2(1, -2).normalized(),
    }
}

## _up defines the Cartesian direction which points towards the positive z-axis.
var _up: Vector2

func _ready():
    _up = _UP_VECTOR_LOOKUP[up_orientation].normalized()

func _body_is_above(body: DFUnit) -> bool:
    var p = _UP_VECTOR_PLANE[up_orientation]["P"] - global_position
    var dp = body.global_position - p
    return dp.dot(_UP_VECTOR_PLANE[up_orientation]["N"]) > 0

# TODO(minkezhang): Emit signal to IsometricMap instead.
# TODO(minkezhang): Move children between MapLayers instead of worrying about z_index.
func _on_body_entered(body):
    if body is DFUnit:
        if _body_is_above(body):  # come down to current layer down (if tile is on next tile down)
            print(_body_is_above(body))
            (body as DFUnit).proxy_ramp_entered.emit()
        else:  # entering from bottom or side -- only increase Z-index
            pass

func _on_body_exited(body):
    if body is DFUnit:
        if _body_is_above(body):  # increase body z layer
            (body as DFUnit).proxy_ramp_exited.emit()
        else:  # exiting from bottom or side -- decrease Z-index
            pass
