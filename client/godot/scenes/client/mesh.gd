class_name DFClientMapMesh
extends Node2D

@export var debug: bool = false
@export var map: DFClientMap

var c = Color.from_hsv(348, 67, 95)


func _draw():
	if not debug:
		return
	
	# Draw grid lines.
	var r = map.get_used_rect()
	var s = DFClientSettings.GRID_CELL_SIZE
	
	for y in range(r.position.y, r.end.y + 1):
		var from = DFGeo.to_local(
			Vector2i(r.position.x, y) - Vector2i(2, 0),
		) - Vector2(0, s.y / 2)
		var to = DFGeo.to_local(
			Vector2i(r.end.x, y) + Vector2i(0, 0),
		) - Vector2(0, s.y / 2)
		draw_line(from, to, c, -1, false)
	
	for x in range(r.position.x, r.end.x + 1):
		var from = DFGeo.to_local(
			Vector2i(x, r.position.y) - Vector2i(0, 1),
		) - Vector2(s.x / 2, 0)
		var to = DFGeo.to_local(
			Vector2i(x, r.end.y) + Vector2i(0, 1),
		) - Vector2(s.x / 2, 0)
		draw_line(from, to, c, -1, false)
	
	# Mark origin tile.
	var origin = PackedVector2Array([
		Vector2i(s.x / 2, 0),
		Vector2i(s.x, s.y / 2),
		Vector2i(s.x / 2, s.y),
		Vector2i(0, s.y / 2),
	])
	draw_polygon(origin, [ Color(c, 0.5) ])
	
	# Mark X+ and Y+ axis.
	draw_line(s / 2, Vector2i(s.x, 0), c, -1, false)
	draw_line(s / 2, s, c, -1, false)
