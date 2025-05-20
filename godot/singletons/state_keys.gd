# Module defines the list of world state dictionary key strings when
# communicating between server and client.
#
# In order to minimize data transfer, we may need compress the key length. This
# allows us to keep scripts readable.
#
# TODO(minkezhang): Move to the common project.
extends Node
class_name DFStateKeys

const ServerTimestamp = "server_timestamp"
const Players = "players"

# Curves
const CurveType = "curve_type"
const Timestamps = "timestamps"
const Data = "data"
const DefaultValue = "default_value"
