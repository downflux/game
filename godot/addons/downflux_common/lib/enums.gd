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
	
	## Return all data.
	FILTER_ALL = (
		FILTER_CURVES
		| FILTER_PLAYERS
	)
}

## Define game factions. Each meaningful object in the game belongs to some
## faction.
enum Faction {
	FACTION_NEUTRAL,
	FACTION_ALPHA,
	FACTION_BETA,
}
