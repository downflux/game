class_name DFClientState
extends Node

var _messages: Array[Dictionary]


func enqueue_state(state: Dictionary):
	_messages.append(state)


func _process(_delta):
	for m in _messages:
		Logger.debug("processing server value \n%s" % [JSON.stringify(m, "\t")])
	_messages = []
