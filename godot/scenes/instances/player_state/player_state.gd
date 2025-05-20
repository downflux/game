# Module which defines the totality of the player game state.
#
# This state contains both user authentication details (e.g. login mint) as well
# as game state, e.g. list of units this player controls, etc.
extends Node
class_name PlayerState

var _anonymous_usernames = [
	"Thing 1",
	"Thing 2",
	"Thing 3",
]

var session_id: int = 0  # Populated by server.gd.

# User authentication properties
var username: String = ""
@onready var alias: String = _anonymous_usernames.pick_random()

# Game state properties
var faction: String = ""  # TODO(minkezhang): Change to enum.
var money: DFCurveFloat = DFCurveFloat.new()
var units: Dictionary[int, bool] = {}  # { unit_id: int -> bool }; units stored in WorldState.


# Serialize data to be exported when e.g. saving game and communicating with
# client.
func to_dict(permission: DFEnums.Permission) -> Dictionary:
	return {
		"username": username if permission >= DFEnums.Permission.PERMISSION_FULL else alias,
		"faction": faction,
		"money": money.to_dict(permission),
		"units": units if permission >= DFEnums.Permission.PERMISSION_FULL else {},
	}
