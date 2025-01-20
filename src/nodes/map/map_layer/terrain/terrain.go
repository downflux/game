package terrain

import (
	"graphics.gd/classdb"
	"graphics.gd/classdb/Resource"
	"graphics.gd/classdb/TileMapLayer"
	"graphics.gd/classdb/TileSet"
)

const (
	path = "res://assets/tilesets/terrain.tres"
)

type N struct {
	classdb.Extension[N, TileMapLayer.Instance] `gd:"DFMapLayer"`

	classdb.Tool
}

func (n *N) Ready() {
	n.Super().AsTileMapLayer().SetTileSet(
		Resource.Load[TileSet.Instance](path))
	n.Super().AsCanvasItem().SetYSortEnabled(true)
}
