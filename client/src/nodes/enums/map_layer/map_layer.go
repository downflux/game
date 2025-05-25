package map_layer

import (
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

func (l *L) Bitmask() (Bitmask, bool) {
	m := map[L]Bitmask{
		Layers.Ground:     BitmaskGround,
		Layers.Air:        BitmaskAir,
		Layers.Sea:        BitmaskSea,
		Layers.Amphibious: BitmaskAmphibious,
	}

	if b, ok := m[*l]; !ok {
		return BitmaskUnknown, false
	} else {
		return b, true
	}
}

var Layers = Enum.Values[L]()
