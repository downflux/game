extends Area2D

signal unit_move_up(unit: CharacterBody2D)
signal unit_move_down(unit: CharacterBody2D)

func _on_body_entered(body):
	body = body as DFUnit
	var v = body.df_unit.velocity2d(DFUnit3D.ProjectionMode.CARTESIAN)
	if body.z_index == 1 and v.dot(Vector2.UP) > 0:
		unit_move_up.emit(body)
		body.z_index = 3

func _on_body_exited(body):
	body = body as DFUnit
	var v = body.df_unit.velocity2d(DFUnit3D.ProjectionMode.CARTESIAN)
	if body.z_index == 3 and v.dot(Vector2.DOWN) > 0:
		unit_move_down.emit(body)
		body.z_index = 1
