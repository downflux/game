class_name DFEnums
extends Node

enum DataFilter {
	FILTER_NONE    = 0,
	FILTER_CURVES  = 1 << 1,
	FILTER_PLAYERS = 1 << 2,
	
	FILTER_ALL = (
		FILTER_CURVES
		| FILTER_PLAYERS
	)
}
