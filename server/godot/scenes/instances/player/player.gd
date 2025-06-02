class_name DFServerPlayer
extends DFStateBase

var state: DFPlayer = DFPlayer.new()


# Server-populated vars.
#
# These are not visible to other players and therefore not tracked by is_dirty.

## Session ID of the client. This is dictated by the incoming RPC ID received
## from [method DFServer.server_request_subscription].
var session_id: int

## Node ID as reported by the client. This node [b]must[/b] exist on the client
## and will receive the data sent by [method DFServer.client_publish_state].
var node_id: int

## If [code]true[/code], the server will attempt to push data to this client.
var is_subscribed: bool

## If [code]false[/code], the server will send the [i]complete[/i] [DFState] on
## the next call to [method DFServer.client_publish_state], and then set to
## [code]true[/code]. Otherwise, only server-side objects with
## [member DFStateBase.is_dirty] set will be sent to the client.
var request_partial: bool

var player_id: String

var _anonymous_usernames = [
	"Thing 1",
	"Thing 2",
	"Thing 3",
]

## If [code]true[/code], the player [member DFPlayer.username] will be hidden
## from other clients.
var streamer_mode: bool
@onready var _alias: String = _anonymous_usernames.pick_random()


func to_dict(
	sid: int,
	partial: bool,
	query: Dictionary,
) -> Dictionary:
	if partial and not is_dirty:
		return {}
	
	if sid != 1 and sid != session_id:
		query.erase(DFStateKeys.KDFPlayerMoney)
	
	var data = state.to_dict(sid, partial, query)
	if (
		query.get(DFStateKeys.KDFPlayerUsername, false)
	) and (
		sid != 1
	) and (
		sid != session_id
	) and streamer_mode:
		data[DFStateKeys.KDFPlayerUsername] = _alias
	
	return data
