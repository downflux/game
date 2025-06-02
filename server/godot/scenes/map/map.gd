class_name DFServerMap
extends Node
## Generates a server-side map for pathfinding.


@export var player_map: PackedScene


@onready var _map_layer_lookup: Dictionary[DFEnums.MapLayer, DFPathfinder] = {
	DFEnums.MapLayer.LAYER_AIR:    $Air,
	DFEnums.MapLayer.LAYER_GROUND: $Ground,
	DFEnums.MapLayer.LAYER_SEA:    $Sea,
}


func get_vector_path(
	src: Vector2i,
	dst: Vector2i,
	map_layer: DFEnums.MapLayer,
) -> Array[Vector2i]:
	return _map_layer_lookup[map_layer].get_vector_path(src, dst)


func _load(map: DFPlayerMap) -> void:
	add_child(map)
	
	for map_layer in _map_layer_lookup:
		_map_layer_lookup[map_layer].configure_pf(map.region, map_layer)
	
	var obstacles = map.get_occupied()
	for map_layer in obstacles:
		for obstacle in obstacles[map_layer]:
			set_solid(obstacle, true, map_layer)
	
	map.queue_free()


func set_solid(target: Variant, solid: bool, map_layer: DFEnums.MapLayer):
	_map_layer_lookup[map_layer].set_solid(target, solid)


func _ready():
	_load(player_map.instantiate(PackedScene.GEN_EDIT_STATE_MAIN))
