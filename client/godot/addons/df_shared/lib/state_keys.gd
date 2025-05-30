class_name DFStateKeys
extends Node
# Module defines the list of world state dictionary key strings when
# communicating between server and client.
#
# In order to minimize data transfer, we may need compress the key length. This
# allows us to keep scripts readable.
#
# TODO(minkezhang): Move to the common project.

const KDFPartial = "partial"
const KDFIsFreed = "is_freed"

const KDFTimestampMSec = "timestamp_msec"
const KDFState         = "state"
const KDFPlayers       = "players"

# TODO(minkezhang): Implement these.
const KDFUnits     = "units"
const KDFBuildings = "buildings"
const KDFEntities  = "entities"

# Players
const KDFPlayerUsername = "username"
const KDFPlayerMoney    = "money"
const KDFPlayerFaction  = "faction"

# Curves
const KDFCurveType         = "curve_type"
const KDFCurveTimestamps   = "timestamps"
const KDFCurveData         = "data"
const KDFCurveDefaultValue = "default_value"
