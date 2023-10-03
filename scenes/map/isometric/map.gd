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
    node.z_index = Layer.z_index(node.z_layer + 1, Layer.RenderLayer.UNIT)

var _layer_move_candidates: Dictionary = {}
enum MoveType { UP, DOWN }
class _LayerMove:
    var _type: MoveType
    var _source_z_layer: int
    var _target_z_layer: int
    var _count: int
    func _init(type: MoveType, source_z_layer: int):
        _type = type
        _source_z_layer = source_z_layer
        _count = 0
        if _type == MoveType.UP:
            _target_z_layer = _source_z_layer + 1
        else:
            _target_z_layer= _source_z_layer - 1

func _process(_delta):
    for node in _layer_move_candidates:
        var m = _layer_move_candidates[node]
        node.z_layer = m._target_z_layer
        node.z_index = Layer.z_index(node.z_layer + 1, Layer.RenderLayer.UNIT)

    _layer_move_candidates = {}

func _on_child_entered_tree(node):
    if node is DFUnit:
        _add_unit(node)

func _on_z_layer_up(collision_z_layer: int, node: DFUnit):
    var m = _layer_move_candidates.get(node, _LayerMove.new(MoveType.UP, collision_z_layer - 1))
    m._count = m._count + 1 if m._type == MoveType.UP else m._count - 1
    if m._count == 0:
        
    if node not in _layer_move_candidates:
        _layer_move_candidates[node] = _LayerMove.new(MoveType.UP, collision_z_layer - 1)
    else:
        m = _layer_move_candidates[node]
        

func _on_z_layer_down(collision_z_layer: int, node: DFUnit):
    if node not in _layer_move_candidates:
        _layer_move_candidates[node] = _LayerMove.new(MoveType.DOWN, collision_z_layer)
