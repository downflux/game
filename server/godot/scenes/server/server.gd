class_name DFServer
extends Node

## Server listening port.
@export var port: int = 7777

## Max number of clients which can connect to this server.
@export var max_clients: int = 4

@export var _verbosity: Logger.VERBOSITY_LEVEL = Logger.VERBOSITY_LEVEL.INFO
@export var _use_native_logging: bool = true

# Convenience lookup modules
@onready var player_verification: DFPlayerVerification = $PlayerVerification
@onready var state: DFState = $State


func _on_peer_connected(sid: int):
	Logger.debug("user connected: %s" % [sid])
	var p = player_verification.verify(sid)
	if p != null:
		state.players.add_child(p, true)


func _on_peer_disconnected(sid: int):
	Logger.debug("user disconnected: %s" % [sid])
	# TODO(minkezhang): Save game data. This is especially useful for when clients
	# disconnect temporarily.
	var p = state.players.get_player(sid)
	p.is_subscribed = false
	p.is_deleted = true


func _ready():
	Logger.verbosity = _verbosity
	Logger.use_native = _use_native_logging
	
	_start(port, max_clients)


func _publish_state(p: DFPlayer):
	if not p.is_subscribed:
		return
	
	if not p.is_dirty and p.request_partial:
		return
	
	var data = {
		DFStateKeys.KDFState: state.to_dict(
			p.session_id,
			p.request_partial,
			DFQuery.generate(
				DFEnums.DataFilter.FILTER_ALL,
			).get(DFStateKeys.KDFState, {})
		),
		DFStateKeys.KDFPartial: p.request_partial,
	}
	p.request_partial = true
	
	client_publish_state.rpc_id(p.session_id, p.node_id, data)


func _physics_process(_delta):
	# The state node as a child of server is processed before server. Broadcast
	# updated date to all clients.
	for p in state.players.get_children():
		_publish_state(p)


func _start(p: int, c: int):
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(p, c)
	
	multiplayer.multiplayer_peer = peer
	
	Logger.debug("server started")


## Marks an incoming peer connection as a subscriber of the [DFState] data.
## [br][br]
## Clients will set [param nid] indicating which node will handle this data,
## e.g. via [method Node.get_instance_id].
@rpc("any_peer", "call_local", "reliable")
func server_request_subscription(nid: int) -> void:
	var sid = multiplayer.get_remote_sender_id()
	var p = state.players.get_player(sid)
	p.node_id = nid
	p.request_partial = false
	p.is_subscribed = true


# Define client stubs.

## Called by [DFServer] at most once a physics tick to send data to each client.
@rpc("authority", "call_local", "reliable")
func client_publish_state(_nid: int, _value: Dictionary) -> void:
	return
