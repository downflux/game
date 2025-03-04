# DebugMesh overlays a grid on top of the rendered TileMap.
#
# This allows us to easily identify the tile coordinates.
extends Node2D


@export var debug: bool = false


var c = Color.from_hsv(348, 67, 95)


func _draw():
	if debug:
		# Draw grid lines.
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
		
		# Mark origin tile.
		var origin = PackedVector2Array([
			Vector2i(
				get_parent().get_tile_set().get_tile_size().x / 2,
				0,
			),
			Vector2i(
				get_parent().get_tile_set().get_tile_size().x,
				get_parent().get_tile_set().get_tile_size().y / 2,
			),
			Vector2i(
				get_parent().get_tile_set().get_tile_size().x / 2,
				get_parent().get_tile_set().get_tile_size().y,
			),
			Vector2i(
				0,
				get_parent().get_tile_set().get_tile_size().y / 2,
			),
		])
		draw_polygon(origin, [ Color(c, 0.5) ])
		
		# Mark X+ and Y+ axis.
		draw_line(
			get_parent().get_tile_set().get_tile_size() / 2,
			Vector2i(
				get_parent().get_tile_set().get_tile_size().x,
				0,
			), c, -1, false,
		)
		draw_line(
			get_parent().get_tile_set().get_tile_size() / 2,
			get_parent().get_tile_set().get_tile_size(), c, -1, false,
		)
