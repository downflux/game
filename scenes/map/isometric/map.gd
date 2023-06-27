extends Node2D

var _layers: Dictionary = {}

func _ready():
    for n in get_children().filter(func(x): return x is MapLayer):
        assert(
            _layers.get(n.z_layer, null) == null,
            "duplicate map z-layers found",
        )
        _layers[n.z_layer] = n
        
    # Manually add units at load-time, as child_entered_tree is called between
    # _init and _ready, making loading MapLayer instances awkward.
    for n in get_children().filter(func(x): return x is DFUnit):
        _add_unit(n)
    
    child_entered_tree.connect(_on_child_entered_tree)

func _add_unit(node: DFUnit):
    node.proxy_z_layer_up.connect(_on_z_layer_up.bind(node as DFUnit))
    node.proxy_z_layer_down.connect(_on_z_layer_down.bind(node as DFUnit))
    remove_child(node)
    _layers[node.z_layer].add_child(node)

func _on_child_entered_tree(node):
    if node is DFUnit:
        _add_unit(node)

func _on_z_layer_up(collision_z_layer: int, node: DFUnit):
    print("Collision detected on %s to move node up" % collision_z_layer)
    # _layers[source_z_layer].remove_child(unit)
    # _layers[target_z_layer].add_child(unit)

func _on_z_layer_down(collision_z_layer: int, node: DFUnit):
    print("Collision detected on %s to move node down" % collision_z_layer)
