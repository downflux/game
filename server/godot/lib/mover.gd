class_name DFServerMoverBase
extends Node

signal tile_changed(tile: Vector2i, occupied: bool)

@warning_ignore_start("unused_parameter")
func set_tiles(timestamp: int):
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
