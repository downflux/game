class_name DFStateKeys
extends Node
# Module defines the list of world state dictionary key strings when
# communicating between server and client.
#
# In order to minimize data transfer, we may need compress the key length. This
# allows us to keep scripts readable.

const KDFPartial = "partial"
const KDFIsFreed = "is_freed"

const KDFTimestampMSec = "timestamp_msec"
const KDFState         = "state"
const KDFPlayers       = "players"
const KDFUnits         = "units"

# TODO(minkezhang): Implement these.
const KDFBuildings = "buildings"
const KDFEntities  = "entities"

# Players
const KDFPlayerID       = "player_id"  # Session ID, not the real player ID
const KDFPlayerUsername = "username"
const KDFPlayerMoney    = "money"
const KDFPlayerFaction  = "faction"

# Units
const KDFUnitID       = "unid_id"
const KDFUnitType     = "unit_type"
const KDFUnitMapLayer = "map_layer"
const KDFUnitPosition = "position"
const KDFUnitTheta    = "theta"
const KDFUnitHealth   = "health"
const KDFUnitFaction  = "faction"

# Curves
const KDFCurveType          = "curve_type"
const KDFCurveTimestampMSec = "timestamps_msec"
const KDFCurveData          = "data"
const KDFCurveDefaultValue  = "default_value"
