extends Area2D

class_name ZTransitionBase

@export var z_layer_down_face: ZTransitionBase.Orientation

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

# Together, _Z_LAYER_DOWN_NORMAL and _Z_LAYER_DOWN_POINT defines a half-plane in
# isometric 2D space, pointing into the lower z plane. This can be used to test
# for when a DFUnit object exits a ramp and should be moved into a separate
# layer.
const _Z_LAYER_DOWN_NORMAL: Dictionary = {
    Orientation.NORTH:     Vector2( 1, -2),
    Orientation.NORTHEAST: Vector2( 1,  0),
    Orientation.EAST:      Vector2( 1,  2),
    Orientation.SOUTHEAST: Vector2( 0,  1),
    Orientation.SOUTH:     Vector2(-1,  2),
    Orientation.SOUTHWEST: Vector2(-1,  0),
    Orientation.WEST:      Vector2(-1, -2),
    Orientation.NORTHWEST: Vector2( 0, -1),
}

const _Z_LAYER_DOWN_POINT: Dictionary = {
    Orientation.NORTH:     Vector2(0,  0),
    Orientation.NORTHEAST: Vector2(0,  0),
    Orientation.EAST:      Vector2(0, 32),
    Orientation.SOUTHEAST: Vector2(0, 16),
    Orientation.SOUTH:     Vector2(0, 32),
    Orientation.SOUTHWEST: Vector2(0,  0),
    Orientation.WEST:      Vector2(0,  0),
    Orientation.NORTHWEST: Vector2(0, 16),
}

func _on_tree_entered():
    # Ramp scenes must be rendered as part of the map.
    _z_layer = (get_parent().get_parent() as MapLayer).z_layer

func _init():
    tree_entered.connect(_on_tree_entered)

func _is_below_tile(body: DFUnit) -> bool:
    var p = global_position + _Z_LAYER_DOWN_POINT[z_layer_down_face]
    var dp = body.global_position - p
    return dp.dot(_Z_LAYER_DOWN_NORMAL[z_layer_down_face]) > 0

func _on_body_entered(body):
    if body is DFUnit:
        # A unit is detected moving into the collision area from the negative z
        # plane, and is approaching from the layer immediately below.
        if _is_below_tile(body) and body.z_layer == _z_layer - 1:
            body.proxy_z_layer_up.emit(_z_layer)

func _on_body_exited(body):
    if body is DFUnit:
        if _is_below_tile(body) and body.z_layer == _z_layer:
            body.proxy_z_layer_down.emit(_z_layer)
