class_name DFServer
extends Node

const _PHYSICS_TICKS_PER_SECOND: int = 10

## Server listening port.
@export var port: int = 7777

## Max number of clients which can connect to this server.
@export var max_clients: int = 4

@export var _verbosity: Logger.VERBOSITY_LEVEL = Logger.VERBOSITY_LEVEL.INFO
@export var _use_native_logging: bool = true

# Convenience lookup modules
@onready var player_verification: DFPlayerVerification = $PlayerVerification
@onready var state: DFServerState = $State
@onready var unit_factory: DFServerUnitFactory = $UnitFactory


func _on_peer_connected(sid: int):
	Logger.debug("user connected: %s" % [sid])
	var p = player_verification.verify(sid)
	if p != null:
		state.players.add_player(p)
	
		state.units.add_unit(unit_factory.create_unit())


func _on_peer_disconnected(sid: int):
	Logger.debug("user disconnected: %s" % [sid])
	# TODO(minkezhang): Save game data. This is especially useful for when clients
	# disconnect temporarily.
	var p = state.players.get_player(sid)
	p.is_subscribed = false
	p.is_deleted = true


func _ready():
	# Setting the physics FPS as a project setting seems to impact the Godot
	# editor itself.
	Engine.set_physics_ticks_per_second(_PHYSICS_TICKS_PER_SECOND)
	
	Logger.verbosity = _verbosity
	Logger.use_native = _use_native_logging
	
	_start(port, max_clients)


func _publish_state(p: DFServerPlayer):
	if not p.is_subscribed or (
		not state.is_dirty and p.request_partial
	):
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
	
	client_publish_state.rpc_id(p.session_id, data)


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
func server_request_subscription():
	var sid = multiplayer.get_remote_sender_id()
	var p = state.players.get_player(sid)
	p.request_partial = false
	p.is_subscribed = true


## Request server to calculate a path for a unit or set of units.
## [br][br]
## TODO(minkezhang): Send unit UUID instead of src Vector2i.
@rpc("any_peer", "call_local", "reliable")
func server_request_move(nid: int, src: Vector2i, dst: Vector2i):
	client_send_path.rpc_id(
		multiplayer.get_remote_sender_id(),
		nid,
		state.map.get_vector_path(
			src,
			dst,
			DFEnums.MapLayer.LAYER_GROUND,
		),
	)


# Define client stubs.

## [DFServer] pushes game state to each client most once a physics tick.
@rpc("authority", "call_local", "reliable")
func client_publish_state(_value: Dictionary):
	return


## Push planned path to requesting client.
@rpc("authority", "call_local", "reliable")
func client_send_path(_nid: int, _path: Array[Vector2i]):
	return
