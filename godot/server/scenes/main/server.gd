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


func _ready():
	start(PORT, MAX_CLIENTS)


func start(port: int, max_clients: int):
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	PEER.create_server(port, max_clients)
	
	multiplayer.multiplayer_peer = PEER
	
	info("server started")
