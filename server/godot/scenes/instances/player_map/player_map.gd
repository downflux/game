@tool
class_name DFPlayerMap
extends Node
## Player-editable [DFPlayerMap], used to describe the terrain of a game map.
## Each instance [b]only[/b] shows the terrain layout, not buildings
## or units.
## [br][br]
## TODO(minkezhang): Allow [DFPlayerMap] to include data structures for saving
## units and buildings, and load them into the game.

@export var region: Rect2i

@onready var _map_layer_lookup: Dictionary[DFServerEnums.MapLayer, DFPlayerMapLayer] = {
	DFServerEnums.MapLayer.LAYER_AIR:    $Air,
	DFServerEnums.MapLayer.LAYER_GROUND: $Ground,
	DFServerEnums.MapLayer.LAYER_SEA:    $Sea,
}


func get_obstacles() -> Dictionary[DFServerEnums.MapLayer, Array]:
	var occupied = {} as Dictionary[DFServerEnums.MapLayer, Array]
	for map_layer in _map_layer_lookup.keys():
		occupied[map_layer] = _map_layer_lookup[map_layer].get_occupied()
	return occupied


func _ready():
	if Engine.is_editor_hint():
		for map_layer in _map_layer_lookup.keys():
			_map_layer_lookup[map_layer].map_layer = map_layer
