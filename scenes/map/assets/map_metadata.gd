extends Resource

## DFMapMetadata instantiates all DFTile configs at game start.

class_name DFMapMetadata

var _INVALID: DFTile = DFTile.new()

var _tiles: Array[DFTile] = [
	# Add TERRAIN
	DFTile.new(
		DFTile.T.TERRAIN, DFTile.B.GRASS, DFTile.O.NONE,
		Vector4i(0, 0, 0, DFTile.SchematicTileSet.GROUND),
	),
	DFTile.new(
		DFTile.T.TERRAIN, DFTile.B.WATER, DFTile.O.NONE,
		Vector4i(1, 0, 0, DFTile.SchematicTileSet.GROUND),
	),
	
	# Add RAMP
	DFTile.new(
		DFTile.T.RAMP, DFTile.B.GRASS, DFTile.O.N,
		Vector4i(0, 0, 1, DFTile.SchematicTileSet.GROUND),
	),
	DFTile.new(
		DFTile.T.RAMP, DFTile.B.GRASS, DFTile.O.NE,
		Vector4i(1, 0, 1, DFTile.SchematicTileSet.GROUND),
	),
	DFTile.new(
		DFTile.T.RAMP, DFTile.B.GRASS, DFTile.O.E,
		Vector4i(2, 0, 1, DFTile.SchematicTileSet.GROUND),
	),
	DFTile.new(
		DFTile.T.RAMP, DFTile.B.GRASS, DFTile.O.SE,
		Vector4i(3, 0, 1, DFTile.SchematicTileSet.GROUND),
	),
	DFTile.new(
		DFTile.T.RAMP, DFTile.B.GRASS, DFTile.O.S,
		Vector4i(4, 0, 1, DFTile.SchematicTileSet.GROUND),
	),
	DFTile.new(
		DFTile.T.RAMP, DFTile.B.GRASS, DFTile.O.SW,
		Vector4i(5, 0, 1, DFTile.SchematicTileSet.GROUND),
	),
	DFTile.new(
		DFTile.T.RAMP, DFTile.B.GRASS, DFTile.O.W,
		Vector4i(6, 0, 1, DFTile.SchematicTileSet.GROUND),
	),
	DFTile.new(
		DFTile.T.RAMP, DFTile.B.GRASS, DFTile.O.NW,
		Vector4i(7, 0, 1, DFTile.SchematicTileSet.GROUND),
	),
	
	# Add RAMP_TOP
	DFTile.new(
		DFTile.T.RAMP_TOP, DFTile.B.GRASS, DFTile.O.N,
		Vector4i(0, 1, 1, DFTile.SchematicTileSet.GROUND),
	),
	DFTile.new(
		DFTile.T.RAMP_TOP, DFTile.B.GRASS, DFTile.O.NE,
		Vector4i(1, 1, 1, DFTile.SchematicTileSet.GROUND),
	),
	DFTile.new(
		DFTile.T.RAMP_TOP, DFTile.B.GRASS, DFTile.O.E,
		Vector4i(2, 1, 1, DFTile.SchematicTileSet.GROUND),
	),
	DFTile.new(
		DFTile.T.RAMP_TOP, DFTile.B.GRASS, DFTile.O.SE,
		Vector4i(3, 1, 1, DFTile.SchematicTileSet.GROUND),
	),
	DFTile.new(
		DFTile.T.RAMP_TOP, DFTile.B.GRASS, DFTile.O.S,
		Vector4i(4, 1, 1, DFTile.SchematicTileSet.GROUND),
	),
	DFTile.new(
		DFTile.T.RAMP_TOP, DFTile.B.GRASS, DFTile.O.SW,
		Vector4i(5, 1, 1, DFTile.SchematicTileSet.GROUND),
	),
	DFTile.new(
		DFTile.T.RAMP_TOP, DFTile.B.GRASS, DFTile.O.W,
		Vector4i(6, 1, 1, DFTile.SchematicTileSet.GROUND),
	),
	DFTile.new(
		DFTile.T.RAMP_TOP, DFTile.B.GRASS, DFTile.O.NW,
		Vector4i(7, 1, 1, DFTile.SchematicTileSet.GROUND),
	),
	
	# Add RAMP_SET_A
	DFTile.new(
		DFTile.T.RAMP_SET_A, DFTile.B.GRASS, DFTile.O.N,
		Vector4i(0, 2, 1, DFTile.SchematicTileSet.GROUND)
	),
	DFTile.new(
		DFTile.T.RAMP_SET_A, DFTile.B.GRASS, DFTile.O.E,
		Vector4i(9, 2, 1, DFTile.SchematicTileSet.GROUND)
	),
	DFTile.new(
		DFTile.T.RAMP_SET_A, DFTile.B.GRASS, DFTile.O.S,
		Vector4i(3, 5, 1, DFTile.SchematicTileSet.GROUND)
	),
	DFTile.new(
		DFTile.T.RAMP_SET_A, DFTile.B.GRASS, DFTile.O.W,
		Vector4i(6, 5, 1, DFTile.SchematicTileSet.GROUND)
	),
	
	# Add RAMP_SET_B
	DFTile.new(
		DFTile.T.RAMP_SET_B, DFTile.B.GRASS, DFTile.O.N,
		Vector4i(3, 2, 1, DFTile.SchematicTileSet.GROUND)
	),
	DFTile.new(
		DFTile.T.RAMP_SET_B, DFTile.B.GRASS, DFTile.O.E,
		Vector4i(6, 2, 1, DFTile.SchematicTileSet.GROUND)
	),
	DFTile.new(
		DFTile.T.RAMP_SET_B, DFTile.B.GRASS, DFTile.O.S,
		Vector4i(0, 5, 1, DFTile.SchematicTileSet.GROUND)
	),
	DFTile.new(
		DFTile.T.RAMP_SET_B, DFTile.B.GRASS, DFTile.O.W,
		Vector4i(9, 5, 1, DFTile.SchematicTileSet.GROUND)
	),
	
	# Add CLIFF
	DFTile.new(
		DFTile.T.CLIFF, DFTile.B.GRASS, DFTile.O.N,
		Vector4i(0, 0, 0, DFTile.SchematicTileSet.CLIFF)
	),
	DFTile.new(
		DFTile.T.CLIFF, DFTile.B.GRASS, DFTile.O.NE,
		Vector4i(1, 0, 0, DFTile.SchematicTileSet.CLIFF)
	),
	DFTile.new(
		DFTile.T.CLIFF, DFTile.B.GRASS, DFTile.O.E,
		Vector4i(4, 0, 0, DFTile.SchematicTileSet.CLIFF)
	),
	DFTile.new(
		DFTile.T.CLIFF, DFTile.B.GRASS, DFTile.O.SE,
		Vector4i(0, 2, 0, DFTile.SchematicTileSet.CLIFF)
	),
	DFTile.new(
		DFTile.T.CLIFF, DFTile.B.GRASS, DFTile.O.S,
		Vector4i(1, 2, 0, DFTile.SchematicTileSet.CLIFF)
	),
	DFTile.new(
		DFTile.T.CLIFF, DFTile.B.GRASS, DFTile.O.SW,
		Vector4i(2, 2, 0, DFTile.SchematicTileSet.CLIFF)
	),
	DFTile.new(
		DFTile.T.CLIFF, DFTile.B.GRASS, DFTile.O.W,
		Vector4i(4, 2, 0, DFTile.SchematicTileSet.CLIFF)
	),
	DFTile.new(
		DFTile.T.CLIFF, DFTile.B.GRASS, DFTile.O.NW,
		Vector4i(4, 2, 0, DFTile.SchematicTileSet.CLIFF)
	),
	
]

var _tags_lookup: Dictionary = {}
var _schematic_atlas_coords_lookup: Dictionary = {}

func _init():
	_tiles.make_read_only()
	
	for i in range(_tiles.size()):
		var t = _tiles[i]
		
		var tags_key = [
			t.get_type(),
			t.get_terrain_base(),
			t.get_orientation(),
		]
		var schematic_atlas_coords_key = t.get_schematic_atlas_coords()
		
		assert(
			not _tags_lookup[tags_key],
			'duplicate tile tags exists for key = {key}'.format({
				'key': tags_key,
			}),
		)
		assert(
			not _schematic_atlas_coords_lookup[schematic_atlas_coords_key],
			'duplicate tile schematics exists for key = {key}'.format({
				'key': schematic_atlas_coords_key,
			}),
		)
		
		_tags_lookup[tags_key] = i
		_schematic_atlas_coords_lookup[schematic_atlas_coords_key] = i

func by_tags(
	tile: DFTile.T,
	terrain_base: DFTile.B,
	orientation: DFTile.O = DFTile.O.NONE,
) -> DFTile:
	return _tiles[
		_tags_lookup[[
			tile,
			terrain_base,
			orientation,
		]]
	]

func by_schematic_atlas_coords(
	schematic_atlas_coords: Vector4i,
):
	return _tiles[
		_schematic_atlas_coords_lookup[schematic_atlas_coords]
	]
