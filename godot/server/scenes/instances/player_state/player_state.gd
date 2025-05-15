# Module which defines the totality of the player game state.
#
# This state contains both user authentication details (e.g. login mint) as well
# as game state, e.g. list of units this player controls, etc.
extends Node

var session_id: int = 0  # Populated by server.gd.

# User authentication properties
var username: String = ""

# Game state properties
var faction: String = ""  # TODO(minkezhang): Change to enum.
var money: int = 0
var units: Dictionary = {}  # { unit_id: int -> bool }; units stored in WorldState.


enum Mode { MODE_PARTIAL, MODE_FULL }


# Serialize data to be exported when e.g. saving game and communicating with
# client.
func serialize(mode: Mode) -> Dictionary:
	var data = {
		"username": username,
		"faction": faction,
		"money": 0,
		"units": units,
	}
	if mode == Mode.MODE_FULL:
		data.merge({
			"money": money,
		})
	return data
