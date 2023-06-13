extends Area2D

signal unit_move_up(unit: CharacterBody2D)
signal unit_move_down(unit: CharacterBody2D)

func _on_body_entered(body):
	print("on_body_entered")
	# body = body as Unit
	print(Vector2(
		body.v().x,
		body.v().y,
		# body.position3().x,
		# body.position3().y,
	).dot(Vector2(-2, 1)))
	if body.z_index == 1 and Vector2(
		body.v().x,
		body.v().y,
		# body.position3().x,
		# body.position3().y,
	).dot(Vector2(-2, 1)) > 0:
		unit_move_up.emit(body)
		body.z_index = 3

func _on_body_exited(body):
	print("on_body_exit")
	# body = body as Unit
	if body.z_index == 3 and Vector2(
		body.v().x,
		body.v().y,
		# body.position3().x,
		# body.position3().y,
	).dot(Vector2(2, -1)) > 0:
		unit_move_down.emit(body)
		body.z_index = 1
