extends Node

var PEER = ENetMultiplayerPeer.new()
@export var HOST = "localhost"
@export var PORT = 7777


func info(s: String):
	print("I %s %s: %s" % [Time.get_time_string_from_system(true), get_script().get_path().split("/")[-1], s])


func _on_connected_to_server():
	info("connected to server: %s:%s" % [HOST, PORT])
	server_foo.rpc_id(1, get_instance_id())

func _on_connection_failed():
	info("failed to connect to server: %s:%s" % [HOST, PORT])


func _on_server_disconnected():
	info("disconnected from server")


func _ready():
	connect_to_server(HOST, PORT)


func connect_to_server(host: String, port: int):
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	PEER.create_client(host, port)
	
	multiplayer.multiplayer_peer = PEER



@rpc("authority", "call_local", "reliable")
func client_fooback(instance: int, value: int):
	info("local scene %d recieved server value %d" % [instance, value])


# Define server stubs.
@rpc("any_peer", "call_local", "reliable")
func server_foo(_instance: int):
	return
