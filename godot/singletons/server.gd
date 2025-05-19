extends Node

var peer = ENetMultiplayerPeer.new()
var _host: String
var _port: int


func _on_connected_to_server():
	Logger.debug("connected to server: %s:%s" % [_host, _port])
	server_request_client_data.rpc_id(1, get_instance_id())


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
func client_receive_client_data(instance: int, value: Dictionary):
	Logger.debug("local scene %d recieved server value %s" % [instance, value])


# Define server stubs.
@rpc("any_peer", "call_local", "reliable")
func server_request_client_data(_instance: int):
	return
