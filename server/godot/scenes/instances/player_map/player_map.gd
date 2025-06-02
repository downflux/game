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

@onready var _map_layer_lookup: Dictionary[DFEnums.MapLayer, DFPlayerMapLayer] = {
	DFEnums.MapLayer.LAYER_AIR:    $Air,
	DFEnums.MapLayer.LAYER_GROUND: $Ground,
	DFEnums.MapLayer.LAYER_SEA:    $Sea,
}


func get_occupied() -> Dictionary[DFEnums.MapLayer, Array]:
	var occupied = {} as Dictionary[DFEnums.MapLayer, Array]
	for map_layer in _map_layer_lookup:
		occupied[map_layer] = _map_layer_lookup[map_layer].get_occupied()
	return occupied


func _ready():
	if Engine.is_editor_hint():
		for map_layer in _map_layer_lookup:
			_map_layer_lookup[map_layer].map_layer = map_layer
