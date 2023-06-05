extends Node

## DFTile defines a Downflux tile configuration metadata object.
##
## This script links all disparate TileSetSource locale data and appends e.g.
## orientation tags to the tile. Each DFTile instance is generated at game start
## and is immutable.

class_name DFTile

## O defines the tile orientation.
enum O {
	NONE,
	
	N, NE, E, SE,
	S, SW, W, NW,
}

## T defines the overarching tile type. Each tile type may have variants.
enum T {
	NONE,
	
	TERRAIN_GRASS,
	TERRAIN_WATER,
	
	RAMP_GRASS,
	RAMP_GRASS_TOP,
	RAMP_SET_A,
	RAMP_SET_B,
	
	CLIFF_GRASS,
}

var _type: T = T.NONE
var _orientation: O = O.NONE
var _schematic_atlas_coords: Vector3i = Vector3i(-1, -1, -1)

func _init(
	type: T = T.NONE,
	orientation: O = O.NONE,
	schematic_atlas_coords: Vector3i = Vector3i(-1, -1, -1),
):
	_type = type
	_orientation = orientation
	_schematic_atlas_coords = schematic_atlas_coords

func type() -> T:
	return _type

func orientation() -> O:
	return _orientation

func schematic_atlas_coords() ->Vector3i:
	return _schematic_atlas_coords
