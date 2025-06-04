class_name DFSettings
extends Node


## Maximum number of keyframes to send in a [method DFCurveBase.to_dict] call.
##
## TODO(minkezhang): Instead implement CURVE_EXPORT_HISTORY_TIME_LIMIT which
## will only export data within the most recent N seconds.
static var CURVE_EXPORT_HISTORY_LIMIT: int = 1000

## Minimum [DFCurveBase] keyframes to keep in memory.
#
## TODO(minkezhang): Instead implement CURVE_HISTORY_TIME_LIMIT which will only
## save data within the most recent N seconds.
static var CURVE_HISTORY_LIMIT: int = 0
