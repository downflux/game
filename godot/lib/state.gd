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
			# If the changes from the node is processed after a call to
			# mark_for_deletion(), all downstream processes are aware of the pending
			# delete operation and will delete remote nodes separately. We can safely
			# remove the node. Since queue_free() removes children as well, there is
			# no need to call queue_free() on children explicitly.
			if is_deleted:
				queue_free()
			
			for c in get_children():
				if c is DFStateBase and c.is_dirty:
					c.is_dirty = v


var is_deleted: bool:
	set(v):
		if v == false:
			return
		
		is_deleted = true
		for c in get_children():
			if c is DFStateBase and not c.is_deleted:
				c.is_deleted = true
		is_dirty = true  # Ensure this change is handled.
	get:
		return is_deleted


# Returns a dict representation of the state of the node.
#
# @param sid The calling session ID. The server session ID is always 1.
# @param partial If set to true and the dirty bit is cleared, return an empty
#  dictionary object.
# @param query The query struct which dictates how to process the data.
func to_dict(
	_sid: int,
	_partial: bool,
	_query: Dictionary,
) -> Dictionary:
	Logger.error("to_dict not implemented")
	
	return {}


func _ready():
	is_dirty = true
