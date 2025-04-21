package main

import (
	"github.com/downflux/gd-game/nodes/example"
	"github.com/downflux/gd-game/nodes/map/constants/layer"
	"github.com/downflux/gd-game/nodes/pathfinder"
	// "github.com/downflux/gd-game/nodes/map/map_layer/potential_map"
	"github.com/downflux/gd-game/nodes/unit"
	"graphics.gd/classdb"
	"graphics.gd/startup"
)

func main() {
	classdb.Register[example.DFExampleNode]()
	classdb.Register[example.DFExampleTileMapLayer]()

	// Load enums in the designated namespace first.
	classdb.Register[layer.N]()

	classdb.Register[pathfinder.N]()
	classdb.Register[unit.N]()
	// classdb.Register[potential_map.N]()

	startup.Engine()
}
