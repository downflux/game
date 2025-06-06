class_name DFSettings
extends Node


## Minimum [DFCurveBase] keyframes to keep in memory.
#
## TODO(minkezhang): Instead implement CURVE_HISTORY_TIME_LIMIT which will only
## save data within the most recent N seconds.
static var CURVE_HISTORY_LIMIT: int = 0
