extends Node

var peer = ENetMultiplayerPeer.new()
var _host: String
var _port: int


func _on_connected_to_server():
	Logger.debug("connected to server: %s:%s" % [_host, _port])
	server_request_subscription.rpc_id(1, get_instance_id())


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
func client_publish_state(nid: int, value: Dictionary) -> void:
	Logger.debug("local scene %d recieved server value \n%s" % [nid, JSON.stringify(value, "\t")])


@rpc("authority", "call_local", "reliable")
func client_send_path(nid: int, path: Array[Vector2i]):
	instance_from_id(nid).set_vector_path(path)


# Define server stubs.

@rpc("any_peer", "call_local", "reliable")
func server_request_subscription(_nid: int) -> void:
	return


@rpc("any_peer", "call_local", "reliable")
func server_request_move(_nid: int, _src: Vector2i, _dst: Vector2i):
	return
