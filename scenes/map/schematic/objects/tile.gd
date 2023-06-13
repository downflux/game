extends Resource

## DFTile defines a Downflux tile configuration metadata object.
##
## This script links all disparate TileSetSource locale data and appends e.g.
## orientation tags to the tile. Each DFTile instance is generated at game start
## and is immutable.

class_name DFTile

## T defines the overarching tile type. Each tile type may have variants.
enum T {
	NONE,
	
	TERRAIN,
	
	RAMP,
	RAMP_TOP,
	RAMP_SET_A,
	RAMP_SET_B,
	
	CLIFF,
}

## O defines the tile orientation.
enum O {
	NONE,
	
	N, NE, E, SE,
	S, SW, W, NW,
}

## B defines the underlying terrain base.
enum B {
	NONE,
	
	GRASS,
	WATER,
}

enum SchematicTileSet {
	NONE,
	
	GROUND,
	CLIFF,
}

var _type: T = T.NONE
var _terrain_base: B = B.NONE
var _orientation: O = O.NONE

## _schematic_atlas_coords is of the form (x, y, source_id, SchematicTileSet).
var _schematic_atlas_coords: Vector4i = Vector4i(-1, -1, -1, SchematicTileSet.NONE)

func _init(
	type: T = T.NONE,
	terrain_base: B = B.NONE,
	orientation: O = O.NONE,
	schematic_atlas_coords: Vector4i = Vector4i(-1, -1, -1, SchematicTileSet.NONE),
):
	_type = type
	_terrain_base = terrain_base
	_orientation = orientation
	_schematic_atlas_coords = schematic_atlas_coords

func get_type() -> T:
	return _type

func get_terrain_base() -> B:
	return _terrain_base

func get_orientation() -> O:
	return _orientation

func get_schematic_atlas_coords() ->Vector4i:
	return _schematic_atlas_coords
