package layer

import (
	"graphics.gd/classdb/Node"
	"graphics.gd/classdb"
	"graphics.gd/variant/Enum"
)

// Bitmask is an internal representation of the different layers in a tile map.
//
// This internal representation is a bitmask.
type Bitmask int

const (
	BitmaskUnknown Bitmask = 0
	BitmaskGround        = 1 << iota
	BitmaskAir
	BitmaskSea

	BitmaskAmphibious = BitmaskGround | BitmaskSea
)

type E Enum.Int[struct {
	Unknown    E `gd:"LAYER_UNKNOWN"`
	Ground     E `gd:"LAYER_GROUND"`
	Air        E `gd:"LAYER_AIR"`
	Sea        E `gd:"LAYER_SEA"`
	Amphibious E `gd:"LAYER_AMPHIBIOUS"`
}]

var EToBitmask = map[E]Bitmask{
	Layers.Ground:     BitmaskGround,
	Layers.Air:        BitmaskAir,
	Layers.Sea:        BitmaskSea,
	Layers.Amphibious: BitmaskAmphibious,
}

var Layers = Enum.Values[E]()

type N struct {
	classdb.Extension[N, Node.Instance] `gd:"DFLayerEnum"`
	Foo E
}

func (n *N) Bar(e E) E { return e } 
