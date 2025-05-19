extends Node

var PEER = ENetMultiplayerPeer.new()
@export var HOST = "localhost"
@export var PORT = 7777


func _on_connected_to_server():
	Logger.info("connected to server: %s:%s" % [HOST, PORT])
	server_request_client_data.rpc_id(1, get_instance_id())


func _on_connection_failed():
	Logger.info("failed to connect to server: %s:%s" % [HOST, PORT])


func _on_server_disconnected():
	Logger.info("disconnected from server")


func _ready():
	Logger.verbosity = Logger.VERBOSITY_LEVEL.DEBUG
	connect_to_server(HOST, PORT)


func connect_to_server(host: String, port: int):
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	PEER.create_client(host, port)
	
	multiplayer.multiplayer_peer = PEER


@rpc("authority", "call_local", "reliable")
func client_receive_client_data(instance: int, value: Dictionary):
	Logger.info("local scene %d recieved server value %s" % [instance, value])


# Define server stubs.
@rpc("any_peer", "call_local", "reliable")
func server_request_client_data(_instance: int):
	return
