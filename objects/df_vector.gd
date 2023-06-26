extends Resource

class_name DFVector

enum Mode {
    CARTESIAN,
    ISOMETRIC,
}

const _ISOMETRIC_TRANSFORM = Transform2D(
    Vector2(0.5,  0.25),
    Vector2(0.5, -0.25),
    Vector2(0, 0)
)

static func flatten(p: Vector3, mode: Mode = Mode.CARTESIAN) -> Vector2:
    if mode == Mode.CARTESIAN:
        return Vector2(p.x, p.y)
    return _ISOMETRIC_TRANSFORM * Vector2(p.x, p.y) + Vector2(0, p.z)

## Returns the Vector3 coordinates of a point in isometric 2D space.
static func inflate(p: Vector2, z: float = 0) -> Vector3:
    var q = _ISOMETRIC_TRANSFORM.affine_inverse() * Vector2(p.x, p.y - z)
    return Vector3(q.x, q.y, z)
