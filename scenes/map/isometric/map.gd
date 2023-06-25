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

func _on_map_layer_unit_transition(unit: DFUnit, source_z_layer: int, target_z_layer: int):
    print("on_map_layer_unit_transition: unit = %s, source = %s, target = %s" % [unit, source_z_layer, target_z_layer])
    return
    _layers[source_z_layer].remove_child(unit)
    _layers[target_z_layer].add_child(unit)
