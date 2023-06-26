extends Node2D

var _layers: Dictionary = {}

func _ready():
    for n in get_children():
        n = n as MapLayer
        if n != null:
            assert(
                _layers.get(n.z_layer, null) == null,
                "duplicate map z-layers found",
            )
            _layers[n.z_layer] = n

func _on_child_entered_tree(node):
    if node is DFUnit:
        node.proxy_z_layer_up.connect(_on_z_layer_up.bind(node as DFUnit))
        node.proxy_z_layer_down.connect(_on_z_layer_down.bind(node as DFUnit))

func _on_z_layer_up(collision_z_layer: int, node: DFUnit):
    print("Collision detected on %s to move node up" % collision_z_layer)
    # _layers[source_z_layer].remove_child(unit)
    # _layers[target_z_layer].add_child(unit)

func _on_z_layer_down(collision_z_layer: int, node: DFUnit):
    print("Collision detected on %s to move node down" % collision_z_layer)
