class_name DFClient
extends Node

@export var host: String = "localhost"
@export var port: int = 7777

@onready var state: DFClientState = $State

var _messages: Array[Dictionary]
var _m_messages: Mutex = Mutex.new()


func _on_state_received(data: Dictionary):
	_m_messages.lock()
	_messages.append(data)
	_m_messages.unlock()


func _ready():
	DFSettings.CURVE_HISTORY_LIMIT = 500
	
	Server.state_received.connect(_on_state_received)
	
	Server.connect_to_server(host, port)


func _process(_delta):
	_m_messages.lock()
	
	for m in _messages:
		state.from_dict(
			m.get(DFStateKeys.KDFPartial, false),
			m.get(DFStateKeys.KDFState, {}),
		)
	_messages = []
	
	_m_messages.unlock()
