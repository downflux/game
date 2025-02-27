package example

import (
	"graphics.gd/classdb"
	"graphics.gd/classdb/Engine"
	"graphics.gd/classdb/Resource"
	"graphics.gd/classdb/TileMapLayer"
	"graphics.gd/classdb/TileSet"
)

const (
	path = "res://assets/tilesets/terrain.tres"
)

type DFExampleTileMapLayer struct {
	classdb.Extension[DFExampleTileMapLayer, TileMapLayer.Instance]

	classdb.Tool
}

func (n *DFExampleTileMapLayer) EnterTree() {
	if Engine.IsEditorHint() {
		n.Super().AsTileMapLayer().SetTileSet(
			Resource.Load[TileSet.Instance](path))
		n.Super().AsCanvasItem().SetYSortEnabled(true)

		/**
		 * Due to poor documentation, it is unclear sometimes what exact API
		 * functions are called. This allows us to do some level of
		 * introspection and get that information.
		 *
		 * t := reflect.TypeOf(n.Super().AsCanvasItem())
		 * for i := 0; i < t.NumMethod(); i++ {
		 * 	m := t.Method(i)
		 * 	fmt.Println(m.Name)
		 * }
		 */
	}
}
