# Module defines the list of world state dictionary key strings when
# communicating between server and client.
#
# In order to minimize data transfer, we may need compress the key length. This
# allows us to keep scripts readable.
#
# TODO(minkezhang): Move to the common project.
extends Node
class_name DFStateKeys

const KDFServerTimestamp = "server_timestamp"
const KDFState           = "state"
const KDFPlayers         = "players"
const KDFUnits           = "units"
const KDFBuildings       = "buildings"

# Players
const KDFPlayerUsername = "username"
const KDFPlayerMoney    = "money"
const KDFPlayerFaction  = "faction"

# Curves
const KDFCurveType         = "curve_type"
const KDFCurveTimestamps   = "timestamps"
const KDFCurveData         = "data"
const KDFCurveDefaultValue = "default_value"
