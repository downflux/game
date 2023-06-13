extends Node2D

var _last_tick_position = Vector2i(position)

const SPEED = 5

func v() -> Vector2:
	return position - _last_tick_position

func _physics_process(delta):
	_last_tick_position = position
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		direction.y /= 2
		position += Vector2(
			direction.normalized().x,
			direction.normalized().y,
		) * SPEED
