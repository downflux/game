class_name DFPlayer
extends DFStateBase
## Defines the totality of the player game state.
## [br][br]
## This state contains both user authentication details (e.g. login mint) as
## well as game state, e.g. the current money of the player, etc.

var _anonymous_usernames = [
	"Thing 1",
	"Thing 2",
	"Thing 3",
]

# Server-populated vars.
#
# These are not visible to other players and therefore not tracked by is_dirty.

## Session ID of the client. This is dictated by the incoming RPC ID received
## from [method DFServer.server_request_subscription].
var session_id: int = 0

## Node ID as reported by the client. This node [b]must[/b] exist on the client
## and will receive the data sent by [method DFServer.client_publish_state].
var node_id: int = 0

## If [code]true[/code], the server will attempt to push data to this client.
var is_subscribed: bool = false

## If [code]false[/code], the server will send the [i]complete[/i] [DFState] on
## the next call to [method DFServer.client_publish_state], and then set to
## [code]true[/code]. Otherwise, only server-side objects with
## [member DFStateBase.is_dirty] set will be sent to the client.
var request_partial: bool = false

# User authentication properties

## If [code]true[/code], the player [member DFPlayer.username] will be hidden
## from other clients.
var streamer_mode: bool = false
var username: String = ""

@onready var _alias: String = _anonymous_usernames.pick_random()

# Game state properties

var faction: DFEnums.Faction
var money: DFCurveFloat          = DFCurveFloat.new(DFCurveBase.Type.TYPE_LINEAR)
var units: Dictionary[int, bool] = {}  # { unit_id: int -> bool }; units stored in WorldState.


func _ready():
	add_child(money)


# Serialize data to be exported when e.g. saving game and communicating with
# client.
func to_dict(sid: int, partial: bool, query: Dictionary) -> Dictionary:
	if partial and not is_dirty:
		return {}
	
	if is_deleted:
		return {
			DFStateKeys.KDFIsFreed: is_deleted,
		}
	
	var data = {}
	
	if query.get(DFStateKeys.KDFPlayerUsername, false):
		data[DFStateKeys.KDFPlayerUsername] = _alias if streamer_mode else username
	if query.get(DFStateKeys.KDFPlayerFaction, false):
		data[DFStateKeys.KDFPlayerFaction] = faction
	if query.get(DFStateKeys.KDFPlayerMoney, false):
		if (not partial or (
			partial and money.is_dirty
		)) and (sid == session_id or sid == 1):
			data[DFStateKeys.KDFPlayerMoney] = money.to_dict(sid, partial, {})

	return data
