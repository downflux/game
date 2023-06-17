extends Area2D

class_name ZTransitionBase

const _MAP_Z_INDEX_BUFFER = 10

## _up defines the Cartesian direction which points towards the positive z-axis.
var _up: Vector2

func up() -> Vector2:
	return _up

func _on_body_entered(body):
	if body is DFUnit and body.df_unit.velocity2d(DFUnit3D.ProjectionMode.CARTESIAN).dot(_up) > 0:
		(body as DFUnit).maybe_set_z_layer(z_index % _MAP_Z_INDEX_BUFFER + 1)
		# TODO(minkezhang): Add queue in DFUnit which tracks entrances and exits for a long ramp.

func _on_body_exited(body):
	if body is DFUnit and body.df_unit.velocity2d(DFUnit3D.ProjectionMode.CARTESIAN).dot(_up) < 0:
		(body as DFUnit).maybe_set_z_layer(z_index % _MAP_Z_INDEX_BUFFER)
