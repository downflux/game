package main

import (
	"github.com/downflux/gd-game/nodes/example"
	"github.com/downflux/gd-game/nodes/pathfinder"
	// "github.com/downflux/gd-game/nodes/map/map_layer/potential_map"
	"github.com/downflux/gd-game/nodes/unit"
	"graphics.gd/classdb"
	"graphics.gd/startup"
)

func main() {
	// N.B.: grow-graphics load enums in the namespace in which it is first
	// used. Order matters in registering classes.

	classdb.Register[example.DFExampleNode]()
	classdb.Register[example.DFExampleTileMapLayer]()

	classdb.Register[pathfinder.N]() // enum: DFNavigation.L

	classdb.Register[unit.N]()
	// classdb.Register[potential_map.N]()

	startup.Engine()
}
