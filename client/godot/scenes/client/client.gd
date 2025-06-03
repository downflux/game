class_name DFClient
extends Node

@export var host: String = "localhost"
@export var port: int = 7777

@onready var state: DFClientState = $State


func _ready():
	Server.state_published.connect(state.enqueue_state)
	
	Server.connect_to_server(host, port)
