extends TileMap

const _RAMP_LAYER: int = 0
const _SOURCE_ID: int = 0

func _ready():
    for i in get_used_cells(_RAMP_LAYER):
        var atlas = get_cell_alternative_tile(_RAMP_LAYER, i)
        var packed = get_tileset().get_source(_SOURCE_ID).get_scene_tile_scene(atlas)
        if packed.instantiate() is ZTransitionBase:
            print(packed.get_state().get_node_path(2))
            # scene.ramp_entered.connect(_on_ramp_entered)
            # scene.ramp_exited.connect(_on_ramp_exited)
    
func _on_ramp_entered(unit: DFUnit):
    print("RAMP_ENTERED")

func _on_ramp_exited(unit: DFUnit):
    print("RAMP_EXITED")
