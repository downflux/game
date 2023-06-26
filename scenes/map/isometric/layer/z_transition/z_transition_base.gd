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

# TODO(minkezhang): Detect the lower z-side instead.
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

func _ready():
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
