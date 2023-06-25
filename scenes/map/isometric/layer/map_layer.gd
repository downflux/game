extends Node2D

class_name MapLayer

@export var z_layer: int = 0

signal unit_transition(unit: DFUnit, source_z_layer: int, target_z_layer: int)

func _ready():
    var l: Layer = Layer.new(z_layer)
    z_index = l.get_z_index()
    $Walls.z_index = Layer.get_z_index_offset(Layer.RenderLayer.WALL)
    $Ground.z_index = Layer.get_z_index_offset(Layer.RenderLayer.GROUND)
    $CollisionBoxes.visible = false
    # position.y -= z_layer * 16

func _on_child_entered_tree(node):
    if node is DFUnit:
        node.proxy_ramp_entered.connect(_on_unit_move_up.bind(node as DFUnit))
        node.proxy_ramp_entered.connect(_on_unit_move_down.bind(node as DFUnit))

func _on_child_exiting_tree(node):
    if node is DFUnit:
        node.proxy_ramp_entered.disconnect(_on_unit_move_up)
        node.proxy_ramp_entered.disconnect(_on_unit_move_down)

func _on_unit_move_up(unit: DFUnit):
    # TODO(minkezhang): Check unit z_layer, only check if map's layer == unit z_layer (or unit.z_layer - 1 to move down)
    unit_transition.emit(unit, z_layer, z_layer + 1)

func _on_unit_move_down(unit: DFUnit):
    unit_transition.emit(unit, z_layer, z_layer - 1)
