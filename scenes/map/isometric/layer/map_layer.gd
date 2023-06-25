extends Node2D

class_name MapLayer

@export var z_layer: int = 0

func _ready():
    var l: Layer = Layer.new(z_layer)
    z_index = l.get_z_index()
    $Walls.z_index = Layer.get_z_index_offset(Layer.RenderLayer.WALL)
    $Ground.z_index = Layer.get_z_index_offset(Layer.RenderLayer.GROUND)
    $CollisionBoxes.visible = false
    # position.y -= z_layer * 16

func _on_child_entered_tree(node):
    if node is DFUnit:
        print("Unit entered layer")

func _on_child_exiting_tree(node):
    if node is DFUnit:
        print("Unit exited layer")
