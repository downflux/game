// Package potential_map applys a scalar field over a 2D grid.
//
// This field is comprised of sources and sinks which decay in a set manner and
// represents the tendency towards a specific path in the grid.
package potential_map

import (
	"math"

	"grow.graphics/gd"
)

type N struct {
	gd.Class[N, gd.Node2D] `gd:"DFPotentialMap"`

	region gd.Rect2i

	// sources represents a 2D grid of individual scalar contributions.
	sources [][]int

	// weights is a scalar cache; this cache may be rebuilt from
	// recalculating the field from the sources.
	weights [][]int

	// Attenuation is a number in the range [0, 1). This designates how
	// strongly any source influence will fade over the map.
	Attenuation float64
}

func (n *N) Ready() {
	n.SetRegion(gd.Rect2i{Position: gd.Vector2i{0, 0}, Size: gd.Vector2i{0, 0}})
}

func (n *N) Clear() { n.Ready() }

// SetRegion preps the node for subsequent use. This must be called before
// calling SetPointWeight.
func (n *N) SetRegion(r gd.Rect2i) {
	n.region = gd.Rect2i{
		Position: r.Position,
		Size:     r.Size,
	}
	n.sources = [][]int{}
	n.weights = [][]int{}
	for i := int64(0); i < r.Size.X(); i++ {
		n.sources = append(n.sources, make([]int, r.Size.Y()))
		n.weights = append(n.weights, make([]int, r.Size.Y()))
	}
}

func (n *N) GetRegion() gd.Rect2i { return n.region }

func (n *N) SetPointWeight(id gd.Vector2i, w int) gd.Error {
	if !n.region.HasPoint(id) {
		return gd.ErrParameterRangeError
	}

	offset := id.Sub(n.region.Position)
	n.applyWeight(offset, 0, -n.sources[offset.X()][offset.Y()])
	n.sources[offset.X()][offset.Y()] = w
	n.applyWeight(offset, 0, w)

	return gd.Ok
}

// applyWeight implements a BFS over the 2D grid and sets some attenuated value
// over the different boarders.
func (n *N) applyWeight(offset gd.Vector2i, depth int32, w int) {
	open := []gd.Vector2i{}
	min := int32(-depth)
	max := int32(depth)
	for i := min; i <= max; i++ {
		open = append(
			open,
			gd.Vector2i{int32(offset.X()) + i, int32(offset.Y()) - depth},
		)
		if depth != 0 {
			open = append(
				open,
				gd.Vector2i{int32(offset.X()) + i, int32(offset.Y()) + depth},
			)
			if i != min && i != max {
				open = append(
					open,
					gd.Vector2i{int32(offset.X()) + depth, int32(offset.Y()) + i},
					gd.Vector2i{int32(offset.X()) - depth, int32(offset.Y()) + i},
				)
			}
		}
	}

	stop := true
	for _, c := range open {
		if n.region.HasPoint(c) {
			l := c.Sub(offset).Length()
			w := math.Floor(float64(w) * math.Pow(n.Attenuation, l))
			if w > 0 {
				stop = false
				n.weights[c.X()][c.Y()] += int(w)
			}
		}
	}

	if !stop {
		n.applyWeight(offset, depth+1, w)
	}
}
