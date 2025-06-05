extends Node

signal state_published(state: Dictionary)

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
	Logger.debug("connected to server: %s:%s" % [_host, _port])
	server_request_subscription.rpc_id(1)


func _on_connection_failed():
	Logger.debug("failed to connect to server: %s:%s" % [_host, _port])


func _on_server_disconnected():
	Logger.debug("disconnected from server")


func connect_to_server(host: String, port: int):
	_host = host
	_port = port
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	peer.create_client(host, port)
	
	multiplayer.multiplayer_peer = peer


@rpc("authority", "call_local", "reliable")
func client_set_server_state_timestamp_msec(timestamp_msec: int):
	server_start_timestamp_msec = int(Time.get_unix_time_from_system() * 1000) - timestamp_msec


@rpc("authority", "call_local", "reliable")
func client_publish_state(value: Dictionary):
	state_published.emit(value)


@rpc("authority", "call_local", "reliable")
func client_send_path(nid: int, path: Array[Vector2i]):
	pass
	# instance_from_id(nid).set_vector_path(path)


# Define server stubs.

@rpc("any_peer", "call_local", "reliable")
func server_request_subscription():
	return


@rpc("any_peer", "call_local", "reliable")
func server_request_move(_nid: int, _uid: int, _dst: Vector2i):
	return
