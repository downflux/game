extends Area2D

class_name ZTransitionBase

@export var up_orientation: ZTransitionBase.Orientation
@export var is_half_cube: bool = false

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

const _MAP_Z_INDEX_BUFFER = 10
const _UP_VECTOR_LOOKUP: Dictionary = {
	Orientation.NORTH: Vector2( 0, -1),
	Orientation.EAST:  Vector2(-1,  0),
	Orientation.SOUTH: Vector2( 0,  1),
	Orientation.WEST:  Vector2( 1,  0),
}

## _up defines the Cartesian direction which points towards the positive z-axis.
var _up: Vector2

func _ready():
	_up = _UP_VECTOR_LOOKUP[up_orientation].normalized()

func _on_body_entered(body):
	if body is DFUnit and body.df_unit.velocity2d(DFUnit3D.ProjectionMode.CARTESIAN).dot(_up) >= 0:
		(body as DFUnit).maybe_set_z_layer(z_index % _MAP_Z_INDEX_BUFFER + 1)
		# TODO(minkezhang): Add queue in DFUnit which tracks entrances and exits for a long ramp.

func _on_body_exited(body):
	if body is DFUnit and body.df_unit.velocity2d(DFUnit3D.ProjectionMode.CARTESIAN).dot(_up) <= 0:
		(body as DFUnit).maybe_set_z_layer(z_index % _MAP_Z_INDEX_BUFFER)
