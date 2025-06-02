class_name DFServerEnums
extends Node

## A cell on a specific map layer may only be occupied by a single obstacle
## type. For example, a [enum DFServerEnums.MapLayer] [code]LAYER_GROUND[/code]
## cell may [b]only[/b] have either an [code]OBSTACLE_TERRAIN[/code] obstacle
## (e.g. cliff) [b]or[/b] an [code]OBSTACLE_STRUCTURE[/code] obstacle
## (e.g. barracks).
enum ObstacleType {
	OBSTACLE_NONE,
	OBSTACLE_TERRAIN,
	OBSTACLE_STRUCTURE,
	OBSTACLE_UNIT,
}

const UNIMPLEMENTED_MAP_LAYERS: Dictionary[DFEnums.MapLayer, bool] = {
	DFEnums.MapLayer.LAYER_AMPHIBIOUS: true,
	DFEnums.MapLayer.LAYER_UNKNOWN: true,
}
