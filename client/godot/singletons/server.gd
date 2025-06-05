extends Node

signal state_received(state: Dictionary)
signal unit_paths_received(paths: Dictionary)

var peer = ENetMultiplayerPeer.new()
var _host: String
var _port: int


var server_start_timestamp_msec: int
var frame_delay_msec: int = 100


func get_server_timestamp_msec() -> int:
	return (
		int(Time.get_unix_time_from_system() * 1000)
	) - (
		server_start_timestamp_msec
	) - frame_delay_msec


func _on_connected_to_server():
	Logger.info("connected to server %s:%s" % [_host, _port])
	s_request_subscription.rpc_id(1)


func _on_connection_failed():
	Logger.warning("failed to connect to server %s:%s" % [_host, _port])


func _on_server_disconnected():
	Logger.warning("disconnected from server")


func connect_to_server(host: String, port: int):
	_host = host
	_port = port
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	peer.create_client(host, port)
	
	multiplayer.multiplayer_peer = peer


@rpc("authority", "call_local", "reliable")
func c_receive_server_start_timestamp_msec(timestamp_msec: int):
	server_start_timestamp_msec = (
		int(Time.get_unix_time_from_system() * 1000)
	) - (
		timestamp_msec
	)


@rpc("authority", "call_local", "reliable")
func c_receive_state(value: Dictionary):
	state_received.emit(value)


@rpc("authority", "call_local", "reliable")
func c_receive_unit_paths(paths: Dictionary):
	unit_paths_received.emit(paths)


# Define server stubs.

@rpc("any_peer", "call_local", "reliable")
func s_request_subscription():
	return


@rpc("any_peer", "call_local", "reliable")
func s_issue_move(_uids: Array[int], _dst: Vector2i):
	return
