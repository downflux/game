class_name DFTimer
extends DFTimerBase

const PHYSICS_TICKS_PER_SECOND: int = 10
const DELTA_MSEC: int = int(float(1000) / PHYSICS_TICKS_PER_SECOND)


func _process(_delta):
	_timestamp_msec = Time.get_ticks_msec()


func get_timestamp_msec() -> int:
	return _timestamp_msec
