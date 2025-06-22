class_name DFTimer
extends Node

const PHYSICS_TICKS_PER_SECOND: int = 10
const DELTA_MSEC: int = int(float(1000) / PHYSICS_TICKS_PER_SECOND)

## Used as server source of truth on the current process time.
##
## Singletons are processed first before other nodes in the scene. This allows
## the server to keep a consistent timestamp across nodes during a single tick
## and removes the need to have a dependency on [class DFServerState].
var _timestamp_msec: int


func _process(_delta):
	var t: int = Time.get_ticks_msec()
	_timestamp_msec = t


func get_timestamp_msec() -> int:
	return _timestamp_msec
