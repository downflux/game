class_name DFClientController
extends Node2D


@export var map: TileMapLayer


func debug_get_tile_coordinates(local: Vector2) -> Vector2i:
	return map.local_to_map(local)


func _input(event: InputEvent):
	# Mouse in viewport coordinates.
	
	var uid: int = 1  # TODO(minkezhang): Select with collision boxes instead.
	
	# Move from current position to mouse click.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_released():
			var e = make_input_local(event)
			var dst = debug_get_tile_coordinates(e.position)
			
			Logger.info("%s request move to %s" % [uid, dst])
			
			Server.server_request_move.rpc_id(1, get_instance_id(), uid, dst)
	
	# Teleport
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_released():
			var e = make_input_local(event)
			# dst = debug_get_tile_coordinates(e.position)
			# $DFUnit.position = dst
