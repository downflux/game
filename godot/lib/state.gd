class_name DFStateBase
extends Node

# is_dirty marks this node as having altered within the most recent tick.
#
# We will propagate setting the dirty bit upwards to the overall server state
# so that we can traverse the tree quickly downwards when exporting the server
# state. We will propagate clearing the dirty bit downwards, as we will call
# this operation from the server state itself after every tick.
var is_dirty: bool:
	set(v):
		is_dirty = v
		if v:
			var p = get_parent()
			if p is DFStateBase and not p.is_dirty:
				p.is_dirty = v
		if not v:
			for c in get_children():
				if c is DFStateBase and c.is_dirty:
					c.is_dirty = v


# Returns a dict representation of the state of the node.
#
# @param sid The calling session ID. The server session ID is always 1.
# @param full If set to false and the dirty bit is cleared, return an empty
#  dictionary object.
# @param query The query struct which dictates how to process the data.
func to_dict(
	_sid: int,
	_full: bool,
	_query: Dictionary,
) -> Dictionary:
	Logger.error("to_dict not implemented")
	
	return {}
