extends Node

@export var _port: int = 7777
@export var _max_clients: int = 4
@export var verbosity: Logger.VERBOSITY_LEVEL = Logger.VERBOSITY_LEVEL.INFO
@export var use_native_logging: bool = true

var peer = ENetMultiplayerPeer.new()

# Convenience lookup modules
@onready var player_verification: Node = $PlayerVerification
@onready var state: Node = $State


func get_player(id: int) -> Player:
	return get_node("State/Players/" + str(id))


func _on_peer_connected(id: int):
	Logger.debug("user connected: %s" % [id])
	player_verification.verify(id)


func _on_peer_disconnected(id: int):
	Logger.debug("user disconnected: %s" % [id])
	# TODO(minkezhang): Save game data. This is especially useful for when clients
	# disconnect temporarily.
	get_player(id).queue_free()


func _ready():
	Logger.verbosity = verbosity
	Logger.use_native = use_native_logging
	
	start(_port, _max_clients)


func start(port: int, max_clients: int):
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	peer.create_server(port, max_clients)
	
	multiplayer.multiplayer_peer = peer
	
	Logger.debug("server started")


@rpc("any_peer", "call_local", "reliable")
func server_request_state(nid: int):
	var sid = multiplayer.get_remote_sender_id()
	var filter = (
		DFEnums.DataFilter.FILTER_PLAYERS 
		| DFEnums.DataFilter.FILTER_CURVES
		| DFEnums.DataFilter.FILTER_UPDATES
	)
	
	var data = {
		DFStateKeys.KDFServerTimestamp: Time.get_unix_time_from_system(),
		DFStateKeys.KDFState: state.to_dict(
			sid,
			filter,
			DFQuery.generate(filter).get(DFStateKeys.KDFState, {})
		)
	}
	
	client_receive_state.rpc_id(sid, nid, data)


# Define client stubs.
@rpc("authority", "call_local", "reliable")
func client_receive_state(_nid: int, _value: Dictionary):
	return
