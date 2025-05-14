extends Node

var PEER = ENetMultiplayerPeer.new()
var PORT = 7777
var MAX_CLIENTS = 4


func info(s: String):
	print("I %s %s: %s" % [Time.get_time_string_from_system(true), get_script().get_path().split("/")[-1], s])


func _on_peer_connected(id: int):
	info("user connected: %s" % [id])


func _on_peer_disconnected(id: int):
	info("user disconnected: %s" % [id])

var mp
func _ready():
	start(PORT, MAX_CLIENTS)
	mp = multiplayer


func start(port: int, max_clients: int):
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	PEER.create_server(port, max_clients)
	
	multiplayer.multiplayer_peer = PEER
	
	info("server started")



@rpc("any_peer", "call_local", "reliable")
func server_foo(instance: int):
	var id = multiplayer.get_remote_sender_id()
	client_fooback.rpc_id(id, instance, 100)


# Define client stubs.
@rpc("authority", "call_local", "reliable")
func client_fooback(_instance: int, _value: int):
	return
