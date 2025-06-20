class_name DFTimer
extends Node

## Used as server source of truth on the current process time.
##
## Singletons are processed first before other nodes in the scene. This allows
## the server to keep a consistent timestamp across nodes during a single tick
## and removes the need to have a dependency on [class DFServerState].
var _timestamp_msec: int


func _process(_delta):
	_timestamp_msec = Time.get_ticks_msec()


func get_timestamp_msec() -> int:
	return _timestamp_msec
