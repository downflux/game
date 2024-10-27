package map_layer

import (
	"fmt"

	"grow.graphics/gd"
)

const (
	path = "res://scenes/level/terrain.tres"
)

type N struct {
	gd.Class[N, gd.TileMapLayer] `gd:"DFMapLayer"`

	gd.Tool
}

func (n *N) Ready() {
	if s, ok := gd.Load[gd.TileSet](n.Temporary, path); !ok {
		fmt.Printf("cannot load TileSet\n")
		return
	} else {
		n.Super().AsTileMapLayer().SetTileSet(s)
	}
	n.Super().AsCanvasItem().SetYSortEnabled(true)
}
