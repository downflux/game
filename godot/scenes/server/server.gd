extends Node

@export var _port: int = 7777
@export var _max_clients: int = 4
@export var verbosity: Logger.VERBOSITY_LEVEL = Logger.VERBOSITY_LEVEL.INFO
@export var use_native_logging: bool = true

# Convenience lookup modules
@onready var player_verification: Node = $PlayerVerification
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
	Logger.verbosity = verbosity
	Logger.use_native = use_native_logging
	
	start(_port, _max_clients)


func _push_data(p: DFPlayer):
	if p.is_subscribed:
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
		
		client_push_state.rpc_id(p.session_id, p.node_id, data)


func _physics_process(_delta):
	# The state node as a child of server is processed before server. Broadcast
	# updated date to all clients.
	if state.is_dirty:
		for p in state.players.get_children():
			_push_data(p)


func start(port: int, max_clients: int):
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port, max_clients)
	
	multiplayer.multiplayer_peer = peer
	
	Logger.debug("server started")


@rpc("any_peer", "call_local", "reliable")
func server_request_subscription(nid: int):
	var sid = multiplayer.get_remote_sender_id()
	var p = state.players.get_player(sid)
	p.node_id = nid
	p.request_partial = false
	p.is_subscribed = true


# Define client stubs.
@rpc("authority", "call_local", "reliable")
func client_push_state(_nid: int, _value: Dictionary):
	return
