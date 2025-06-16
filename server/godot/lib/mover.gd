class_name DFServerMoverBase
extends Node

@warning_ignore_start("unused_signal")
## The unit's characteristic tile has moved and is now occupying a new cell.
## both [param src] and [param dst] may be Vector2.MAX to indicate e.g. the
## unit has just spawned.
signal curr_tile_changed(src: Vector2i, dst: Vector2i)
@warning_ignore_restore("unused_signal")

@warning_ignore_start("unused_signal")
## The unit's pathing has changed such that the horizon is now in a new cell.
## This horizon is checked against a list of occupied cells (i.e. monitored by
## a curr_tile_changed handler) to see if a unit may move into that cell.
signal next_tile_changed(src: Vector2i, dst: Vector2i)
@warning_ignore_restore("unused_signal")


@warning_ignore_start("unused_parameter")
func set_tiles(timestamp_msec: int, delta_msec: int):
	pass
@warning_ignore_restore("unused_parameter")


@warning_ignore_start("unused_parameter")
## Virtual method defining the interface of a movement component.
## [br][br]
## [param timestamp_msec] is passed from
## [property DFServerState.timestamp_msec].
func set_vector_path(timestamp: int, path: Array[Vector2i]):
	pass
@warning_ignore_restore("unused_parameter")
