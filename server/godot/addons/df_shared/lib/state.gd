class_name DFStateBase
extends Node
## Base class representing a server object which needs to be synced with
## clients.

@warning_ignore_start("unused_parameter")
## Virtual method called upon setting the dirty bit.
## [br][br]
## Useful for classes to define additional cleanup methods.
func _on_set_is_dirty(_v: bool):
	pass
@warning_ignore_restore("unused_parameter")


## Marks this node as having been altered within the most recent tick.
## [br][br]
## We will propagate setting the dirty bit upwards to [DFState] so that we can
## traverse the tree quickly downwards when exporting the server state.
## [br][br]
## This property will be set by the root node(s) (e.g. [DFState]) after
## all changes have been processed, and will propagate clearing the dirty bit
## downwards.
var is_dirty: bool:
	set(v):
		is_dirty = v
		self._on_set_is_dirty(v)
		if v:
			var p = get_parent()
			if p is DFStateBase:
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
				if c is DFStateBase:
					c.is_dirty = v

## Marks this node as intended to be deleted at the end of the frame.
## [br][br]
## Subclasses of DFStateBase [b]must[/b] set [member is_deleted] instead of
## calling [member Node.queue_free]. Once set, [member is_deleted] will never be
## toggled back to [code]false[/code].
var is_deleted: bool:
	set(v):
		if v == false:
			return
		
		is_deleted = true
		for c in get_children():
			if c is DFStateBase and not c.is_deleted:
				c.is_deleted = true
		is_dirty = true  # Ensure this change is handled.


@warning_ignore_start("unused_parameter")
## Virtual method that returns a dictionary representation of the state of the
## node.
## [br][br]
## [param sid] is set to the session ID of the requesting player, [b]or[/b] to
## [code]1[/code] for the server session ID. If [param partial] is
## [code]true[/code], this function must return an empty dictionary
## [code]{}[/code] if the dirty bit [param is_dirty] is cleared. [param query]
## is a dictionary object which is used to indicate which fields to include in
## the returned dictionary.
func to_dict(
	sid: int,
	partial: bool,
	query: Dictionary,
) -> Dictionary:
	Logger.error("to_dict not implemented")
	
	return {}
@warning_ignore_restore("unused_parameter")


@warning_ignore_start("unused_parameter")
## Virtual method which takes in a serialized dictionary of the node state and
## updates the node.
## [br][br]
## [param partial] dictates merging behavior. Setting to [code]true[/code] is
## the equivalent of the [code]PATCH[/code] operation, wereas setting to
## [code]false[/code] is the equivalent of [code]PUT[/code].
func from_dict(
	partial: bool,
	data: Dictionary,
):
	Logger.error("to_dict not implemented")
	
	return
@warning_ignore_restore("unused_parameter")


func _init():
	is_dirty = true
