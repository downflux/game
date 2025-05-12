package unit_directory

import (
	"github.com/downflux/gd-game/nodes/enums/map_layer"
	"github.com/downflux/gd-game/nodes/unit"
	"github.com/downflux/gd-game/nodes/enums/team"
	"graphics.gd/variant/Vector2i"
)

type N struct {
	Units map[map_layer.L]map[Vector2i.XY][]unit.N
}
