class_name DFServer
extends Node

## Server listening port.
@export var port: int = 7777

## Max number of clients which can connect to this server.
@export var max_clients: int = 4

@export var logger_verbosity: Logger.VerbosityLevel
@export var logger_message_type: Logger.MessageType = Logger.MessageType.TYPE_NATIVE

# Convenience lookup modules
@onready var player_verification: DFPlayerVerification = $Components/PlayerVerification
@onready var state: DFServerState                      = $State
@onready var unit_factory: DFServerUnitFactory         = $Components/UnitFactory


func _on_peer_connected(sid: int):
	Logger.debug("user connected: %s" % [sid])
	var p = player_verification.verify(sid)
	if p != null:
		state.players.add_player(p)
		
		state.units.add_unit(
			unit_factory.create_unit(
				p.player_state.faction,
			),
		)
	
	c_receive_server_start_timestamp_msec.rpc_id(sid, T.get_timestamp_msec())


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
	Engine.set_physics_ticks_per_second(T.PHYSICS_TICKS_PER_SECOND)
	
	Logger.verbosity = logger_verbosity
	Logger.message_type = logger_message_type
	
	_start(port, max_clients)


func _push_state(p: DFServerPlayer):
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
	
	c_receive_state.rpc_id(p.session_id, data)


func _physics_process(_delta):
	# _physics_process is called in tree order, i.e. DFServer._physics_process is
	# called before DFServerState._physics_process. This is important as the
	# DFServerState manually clears its own is_dirty bit at the end if every
	# physics frame.
	#
	# See
	# https://docs.godotengine.org/en/stable/tutorials/scripting/scene_tree.html#tree-order
	# for more information.
	for p in state.players.get_children():
		_push_state(p)


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
func s_request_subscription():
	var sid = multiplayer.get_remote_sender_id()
	var p = state.players.get_player(sid)
	p.request_partial = false
	p.is_subscribed = true


func _issue_move(sid: int, uids: Array[int], dst: Vector2i):
	var p: DFServerPlayer = state.players.get_player(sid)
	var paths: Dictionary = {}
	
	for uid: int in uids:
		var u: DFServerUnitBase = state.units.get_unit(uid)
		if (
			p != null and u != null
		) and (
			p.player_state.faction == u.unit_state.faction
		):
			var path: Array[Vector2i] = state.get_vector_path(uid, dst)
			state.set_vector_path(uid, path)
			
			paths[uid] = path
	
	c_receive_unit_paths.rpc_id(sid, paths)


## Request server to calculate a path for a unit or set of units.
## [br][br]
## TODO(minkezhang): Send unit UUID instead of src Vector2i.
@rpc("any_peer", "call_local", "reliable")
func s_issue_move(uids: Array[int], dst: Vector2i):
	var sid = multiplayer.get_remote_sender_id()
	
	state.enqueue_user_command(
		sid,
		Callable(
			self,
			"_issue_move",
		).bind(sid, uids, dst)
	)


# Define client stubs.

## [DFServer] pushes game state to each client most once a physics tick.
@rpc("authority", "call_local", "reliable")
func c_receive_state(_value: Dictionary):
	return


## Push planned path to requesting client.
@rpc("authority", "call_local", "reliable")
func c_receive_unit_paths(_paths: Dictionary):
	return


## Sends the timestamp at which the server started.
@rpc("authority", "call_local", "reliable")
func c_receive_server_start_timestamp_msec(_timestamp_msec: int):
	return
