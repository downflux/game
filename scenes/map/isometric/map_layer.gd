extends Node2D

class_name MapLayer

@export var z_layer: int = 0

var _units: Dictionary = {}

func _ready():
    var l: Layer = Layer.new(z_layer)
    z_index = l.get_z_index()
    $Walls.z_index = Layer.get_z_index_offset(Layer.RenderLayer.WALL)
    $Ground.z_index = Layer.get_z_index_offset(Layer.RenderLayer.GROUND)
    $CollisionBoxes.z_index = Layer.get_z_index_offset(Layer.RenderLayer.GROUND)
    $CollisionBoxes.visible = false
    # position.y -= z_layer * 16

func insert_unit(unit: DFUnit):
    assert(_units.get(unit.id(), null) == null, "duplicate unit ID found")
    _units[unit.id()] = unit

func remove_unit(unit: DFUnit):
    assert(_units.get(unit.id(), null) != null, "Cannot find unit with ID %s" % unit.id())
    _units.erase(unit.id())
