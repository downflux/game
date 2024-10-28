extends Node2D


@export var debug: bool = false


var c = Color.from_hsv(348, 67, 95)


func _draw():
	if debug:
		var r = get_parent().get_used_rect()
		var s = get_parent().get_tile_set().get_tile_size()
		
		for y in range(r.position.y, r.end.y + 1):
			var from = get_parent().map_to_local(
				Vector2i(r.position.x, y) - Vector2i(2, 0),
			) - Vector2(0, s.y / 2)
			var to = get_parent().map_to_local(
				Vector2i(r.end.x, y) + Vector2i(0, 0),
			) - Vector2(0, s.y / 2)
			draw_line(from, to, c, -1, false)
		
		for x in range(r.position.x, r.end.x + 1):
			var from = get_parent().map_to_local(
				Vector2i(x, r.position.y) - Vector2i(0, 1),
			) - Vector2(s.x / 2, 0)
			var to = get_parent().map_to_local(
				Vector2i(x, r.end.y) + Vector2i(0, 1),
			) - Vector2(s.x / 2, 0)
			draw_line(from, to, c, -1, false)
