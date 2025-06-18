class_name DFFSM
extends Node

signal state_changed(src: int, dst: int)

class Transition:
	var src: int
	var dst: int
	func _init(src: int, dst: int):
		self.src = src
		self.dst = dst


var state: int:
	get():
		return state
	set(v):
		if transitions.get(state, {}).get(v, false):
			Logger.error("invalid transition: %d --> %d" % [state, v])
		else:
			state_changed.emit(state, v)
			state = v

var transitions: Dictionary:
	set(v):
		transitions = {}
		for t: Transition in v:
			if t.src not in transitions:
				transitions[t.src] = {}
			transitions[t.src][t.dst] = true
