package layer

import (
	"graphics.gd/classdb"
	"graphics.gd/classdb/Node"
	"graphics.gd/variant/Enum"
)

// Bitmask is an internal representation of the different layers in a tile map.
//
// This internal representation is a bitmask.
type Bitmask int

const (
	BitmaskUnknown Bitmask = 0
	BitmaskGround          = 1 << iota
	BitmaskAir
	BitmaskSea

	BitmaskAmphibious = BitmaskGround | BitmaskSea
)

type L Enum.Int[struct {
	Unknown    L `gd:"LAYER_UNKNOWN"`
	Ground     L `gd:"LAYER_GROUND"`
	Air        L `gd:"LAYER_AIR"`
	Sea        L `gd:"LAYER_SEA"`
	Amphibious L `gd:"LAYER_AMPHIBIOUS"`
}]

func (l *L) Bitmask() Bitmask {
	m := map[L]Bitmask{
		Layers.Ground:     BitmaskGround,
		Layers.Air:        BitmaskAir,
		Layers.Sea:        BitmaskSea,
		Layers.Amphibious: BitmaskAmphibious,
	}

	if b, ok := m[l]; !ok {
		return BitmaskUnknown
	} else {
		return b
	}
}

var Layers = Enum.Values[L]()

type N struct {
	classdb.Extension[N, Node.Instance] `gd:"DFLayerEnum"`

	// The namespace of the enum is tied to the first Node instance which
	// uses it.
	UnusedL L
}
