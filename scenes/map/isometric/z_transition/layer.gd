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

var _z_layer: int

func _init(z_layer: int):
	_z_layer = z_layer

func get_z_layer() -> int:
	return _z_layer

func set_z_layer(z_layer: int):
	_z_layer = z_layer

func get_z_index(offset: RenderLayer = RenderLayer.BASE) -> int:
	return _z_layer * _Z_INDICES_PER_LAYER + _Z_INDEX_OFFSET[offset]

static func from_z_index(z_index: int) -> Layer:
	return Layer.new(z_index / _Z_INDICES_PER_LAYER)

static func get_z_index_offset(offset: RenderLayer) -> int:
	return _Z_INDEX_OFFSET[offset]
