extends Area2D

class_name ZTransitionBase

@export var up_orientation: ZTransitionBase.Orientation

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

## _up defines the Cartesian direction which points towards the positive z-axis.
var _up: Vector2

func _ready():
    _up = _UP_VECTOR_LOOKUP[up_orientation].normalized()

# TODO(minkezhang): Emit signal to IsometricMap instead.
# TODO(minkezhang): Move children between MapLayers instead of worrying about z_index.
func _on_body_entered(body):
    if body is DFUnit:
    # if body is DFUnit and body.df_unit.velocity2d(DFUnit3D.ProjectionMode.CARTESIAN).dot(_up) >= 0:
        (body as DFUnit).proxy_ramp_entered.emit()

func _on_body_exited(body):
    if body is DFUnit:
    # if body is DFUnit and body.df_unit.velocity2d(DFUnit3D.ProjectionMode.CARTESIAN).dot(_up) <= 0:
        (body as DFUnit).proxy_ramp_exited.emit()
