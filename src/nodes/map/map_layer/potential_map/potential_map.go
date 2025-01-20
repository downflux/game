// Package potential_map contains all potential map layers for a game instance.
package potential_map

import (
	"github.com/downflux/gd-game/internal/errors"
	"github.com/downflux/gd-game/nodes/map/map_layer/potential_map/layer"
	"graphics.gd/classdb"
	"graphics.gd/classdb/Node2D"
	"graphics.gd/variant/Rect2i"
	"graphics.gd/variant/Vector2i"
)

type (
	LayerID      int // LayerID = LayerTag | LayerTerrain | LayerTeam
	LayerTeam    int // 5 bits
	LayerTerrain int // 4 bits
	LayerTag     int // 7 bits
)

func ToLayerID(team LayerTeam, terrain LayerTerrain, tag LayerTag) LayerID {
	return LayerID(int(team) | int(terrain)<<8 | int(tag)<<16)
}
func (id LayerID) Team() LayerTeam       { return LayerTeam(0x00f | id) }
func (id LayerID) Terrain() LayerTerrain { return LayerTerrain(0x0f0 | id>>8) }
func (id LayerID) Tag() LayerTag         { return LayerTag(0xf00 | id>>16) }

const (
	LayerTeamUnknown = 0

	LayerTerrainUnknown = 0
	LayerTerrainLand    = 1 << iota
	LayerTerrainAir
	LayerTerrainSea

	LayerTagUnknown = 0
	LayerTagTerrain = 1 << iota
	LayerTagUnit
	LayerTagBuilding
)

var (
	lookup = map[LayerTag]float64{
		LayerTagTerrain:  1,
		LayerTagUnit:     0.7,
		LayerTagBuilding: 0.9,
	}
)

type O struct {
	Region Rect2i.PositionSize
}

type N struct {
	classdb.Extension[N, Node2D.Instance] `gd:"DFPotentialMap"`

	region Rect2i.PositionSize
	layers map[LayerID]*layer.N
}

func New(o O) *N {
	n := &N{
		region: o.Region,
		layers: map[LayerID]*layer.N{},
	}
	n.Clear()
	return n
}

func (n *N) Clear() {
	for _, l := range n.layers {
		l.Clear()
		l.SetRegion(n.region)
	}
}

func (n *N) SetPointWeight(mask LayerID, id Vector2i.XY, w int) errors.Error {
	if _, ok := lookup[mask.Tag()]; !ok {
		return errors.ErrParameterRangeError
	}
	if _, ok := n.layers[mask]; !ok {
		n.layers[mask] = layer.New(layer.O{
			Attenuation: lookup[mask.Tag()],
		})
	}
	return n.layers[mask].SetPointWeight(id, w)
}

func (n *N) GetPointWeight(team LayerTeam, terrain LayerTerrain, tag LayerTag, id Vector2i.XY) (int, errors.Error) {
	return 0, errors.Ok
}
