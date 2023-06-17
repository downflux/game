extends Node2D

@export var z_layer: int = 0

const _MAP_Z_BUFFER_PER_LAYER: int = 5

func _ready():
	z_index = z_layer * _MAP_Z_BUFFER_PER_LAYER
