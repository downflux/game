class_name DFEnums
extends Node
## Defines all enums used by both server and client.

## Defines the query options when filtering server data.
enum DataFilter {
	## Return no data.
	FILTER_NONE    = 0,
	
	## Return interpolated state data.
	FILTER_CURVES  = 1 << 1,
	
	## Return all player data.
	FILTER_PLAYERS = 1 << 2,
	
	## Return all unit data.
	FILTER_UNITS = 1 << 4,
	
	## Return all data.
	FILTER_ALL = (
		FILTER_CURVES
		| FILTER_PLAYERS
		| FILTER_UNITS
	)
}

## Define game factions. Each meaningful object in the game belongs to some
## faction.
enum Faction {
	FACTION_NONE,
	FACTION_ALPHA,
	FACTION_BETA,
}

## Define game unit types.
enum UnitType {
	UNIT_NONE,
	UNIT_GI,
}

enum MapLayer {
	LAYER_UNKNOWN,
	LAYER_AIR,
	LAYER_GROUND,
	LAYER_SEA,
	
	## TODO(minkezhang): Implement LAYER_AMPHIBIOUS.
	LAYER_AMPHIBIOUS,
}
