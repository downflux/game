package main

import (
	"github.com/downflux/gd-game/nodes/example"
	// "github.com/downflux/gd-game/nodes/map/map_layer/potential_map"
	"graphics.gd/classdb"
	"graphics.gd/startup"
)

func main() {
	classdb.Register[example.N]()
	classdb.Register[example.DFExampleTileMapLayer]()
	// classdb.Register[potential_map.N]()

	startup.Engine()
}
