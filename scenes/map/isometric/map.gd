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

func move_unit(unit: DFUnit, source: int, target: int):
    _layers[source].remove_unit(unit)
    _layers[target].insert_unit(unit)
