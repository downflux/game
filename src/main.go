package main

import (
	"github.com/downflux/gd-game/nodes/example"
	"github.com/downflux/gd-game/nodes/pathfinder"
	// "github.com/downflux/gd-game/nodes/map/map_layer/potential_map"
	"graphics.gd/classdb"
	"graphics.gd/startup"
)

func main() {
	classdb.Register[example.DFExampleNode]()
	classdb.Register[example.DFExampleTileMapLayer]()
	classdb.Register[pathfinder.N]()
	// classdb.Register[potential_map.N]()

	startup.Engine()
}
