extends Node2D

class_name MapLayer

@export var z_layer: int = 0

func _ready():
    z_index = Layer.z_index(z_layer)
    $Walls.z_index = Layer.z_index_offset(Layer.RenderLayer.WALL)
    $Ground.z_index = Layer.z_index_offset(Layer.RenderLayer.GROUND)
    $CollisionBoxes.visible = false
    position.y -= z_layer * 16
