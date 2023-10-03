extends Resource

class_name Layer

const _Z_INDICES_PER_LAYER: int = 5

enum RenderLayer {
    ERROR_UNSPECIFIED,
    BASE,
    GROUND,
    UNIT,
    WALL,
}

const _Z_INDEX_OFFSET: Dictionary = {
    RenderLayer.BASE:   0,
    RenderLayer.WALL:   0,
    RenderLayer.UNIT:   0,
    RenderLayer.GROUND: 1,
}

static func z_index(z_layer: int, layer: RenderLayer) -> int:
    return z_layer * _Z_INDICES_PER_LAYER + _Z_INDEX_OFFSET[layer]
