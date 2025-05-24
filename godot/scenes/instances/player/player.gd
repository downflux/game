# Module which defines the totality of the player game state.
#
# This state contains both user authentication details (e.g. login mint) as well
# as game state, e.g. list of units this player controls, etc.
extends DFStateBase
class_name Player

var _anonymous_usernames = [
	"Thing 1",
	"Thing 2",
	"Thing 3",
]

var session_id: int = 0  # Populated by server.gd.

# User authentication properties
var username: String = ""
var streamer_mode: bool = false
@onready var alias: String = _anonymous_usernames.pick_random()

# Game state properties
var faction: String = ""  # TODO(minkezhang): Change to enum.
var money: DFCurveFloat = DFCurveFloat.new()
var units: Dictionary[int, bool] = {}  # { unit_id: int -> bool }; units stored in WorldState.


func _ready():
	add_child(money)


# Serialize data to be exported when e.g. saving game and communicating with
# client.
func to_dict(sid: int, full: bool, query: Dictionary) -> Dictionary:
	if not full and not is_dirty:
		return {}
	
	var data = {}
	
	if query.get(DFStateKeys.KDFPlayerUsername, false):
		data[DFStateKeys.KDFPlayerUsername] = alias if streamer_mode else username
	if query.get(DFStateKeys.KDFPlayerFaction, false):
		data[DFStateKeys.KDFPlayerFaction] = faction
	if query.get(DFStateKeys.KDFPlayerMoney, false):
		if (full or (
			not full and money.is_dirty
		)) and (sid == session_id or sid == 1):
			data[DFStateKeys.KDFPlayerMoney] = money.to_dict(sid, full, {})

	return data
