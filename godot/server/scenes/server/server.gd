extends Node

var PEER = ENetMultiplayerPeer.new()
var PORT = 7777
var MAX_CLIENTS = 4


# Convenience lookup modules
@onready var player_verification = $PlayerVerification


func info(s: String):
	print("I %s %s: %s" % [Time.get_time_string_from_system(true), get_script().get_path().split("/")[-1], s])


func _on_peer_connected(id: int):
	info("user connected: %s" % [id])
	player_verification.verify(id)


func _on_peer_disconnected(id: int):
	info("user disconnected: %s" % [id])
	# TODO(minkezhang): Save game data. This is especially useful for when clients
	# disconnect temporarily.
	get_node("State/Players/" + str(id)).queue_free()


func _ready():
	start(PORT, MAX_CLIENTS)


func start(port: int, max_clients: int):
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	PEER.create_server(port, max_clients)
	
	multiplayer.multiplayer_peer = PEER
	
	info("server started")



@rpc("any_peer", "call_local", "reliable")
func server_request_client_data(instance: int):
	var id = multiplayer.get_remote_sender_id()
	client_return_client_data.rpc_id(id, instance, get_node("State/Players/" + str(id)).serialize(0))


# Define client stubs.
@rpc("authority", "call_local", "reliable")
func client_return_client_data(_instance: int, _value: Dictionary):
	return
