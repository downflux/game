class_name DFClient
extends Node

@export var host: String = "localhost"
@export var port: int = 7777

@onready var state: DFClientState = $State

var _messages: Array[Dictionary]
var _m_messages: Mutex = Mutex.new()


func enqueue_state(data: Dictionary):
	while not _m_messages.try_lock():
		pass
	_messages.append(data)
	_m_messages.unlock()


func _ready():
	DFSettings.CURVE_HISTORY_LIMIT = 500
	
	Server.state_published.connect(enqueue_state)
	
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
