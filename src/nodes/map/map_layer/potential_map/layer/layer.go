// Package layer applies a scalar field over a 2D grid.
//
// This field is comprised of sources and sinks which decay in a set manner and
// represents the tendency towards a specific path in the grid.
package layer

import (
	"math"

	"graphics.gd/variant/Rect2i"
	"graphics.gd/variant/Vector2i"
	"github.com/downflux/gd-game/internal/errors"
)

type O struct {
	// Attenuation is a number in the range [0, 1). This designates how
	// strongly any source influence will fade over the map.
	Attenuation float64
}

type N struct {
	// region is the region over which the field is defined.
	region Rect2i.PositionSize

	// sources represents a 2D grid of individual scalar contributions.
	sources [][]int

	// weights is a scalar cache; this cache may be rebuilt from
	// recalculating the field from the sources.
	weights [][]int

	// Attenuation is a number in the range [0, 1). This designates how
	// strongly any source influence will fade over the map.
	Attenuation float64
}

func New(o O) *N {
	n := &N{
		Attenuation: o.Attenuation,
	}
	n.Clear()
	return n
}

func (n *N) Clear() {
	n.SetRegion(Rect2i.PositionSize{Position: Vector2i.XY{0, 0}, Size: Vector2i.XY{0, 0}})
}

// SetRegion preps the node for subsequent use. This must be called before
// calling SetPointWeight.
func (n *N) SetRegion(r Rect2i.PositionSize) {
	n.region = Rect2i.PositionSize{
		Position: r.Position,
		Size:     r.Size,
	}
	n.sources = [][]int{}
	n.weights = [][]int{}
	for i := int32(0); i < r.Size.X; i++ {
		n.sources = append(n.sources, make([]int, r.Size.Y))
		n.weights = append(n.weights, make([]int, r.Size.Y))
	}
}

func (n *N) GetRegion() Rect2i.PositionSize { return n.region }

func (n *N) SetPointWeight(id Vector2i.XY, w int) errors.Error {
	if !Rect2i.HasPoint(n.region, id) {
		return errors.ErrParameterRangeError
	}

	offset := Vector2i.Sub(id, n.region.Position)
	n.applyWeight(offset, 0, -n.sources[offset.X][offset.Y])
	n.sources[offset.X][offset.Y] = w
	n.applyWeight(offset, 0, w)

	return errors.Ok
}

// applyWeight implements a BFS over the 2D grid and sets some attenuated value
// over the different boarders.
func (n *N) applyWeight(offset Vector2i.XY, depth int32, w int) {
	open := []Vector2i.XY{}
	min := int32(-depth)
	max := int32(depth)
	for i := min; i <= max; i++ {
		open = append(
			open,
			Vector2i.XY{int32(offset.X) + i, int32(offset.Y) - depth},
		)
		if depth != 0 {
			open = append(
				open,
				Vector2i.XY{int32(offset.X) + i, int32(offset.Y) + depth},
			)
			if i != min && i != max {
				open = append(
					open,
					Vector2i.XY{int32(offset.X) + depth, int32(offset.Y) + i},
					Vector2i.XY{int32(offset.X) - depth, int32(offset.Y) + i},
				)
			}
		}
	}

	stop := true
	for _, c := range open {
		if Rect2i.HasPoint(n.region, c) {
			l := Vector2i.Length(Vector2i.Sub(c, offset))
			w := math.Floor(float64(w) * math.Pow(n.Attenuation, float64(l)))
			if w > 0 {
				stop = false
				n.weights[c.X][c.Y] += int(w)
			}
		}
	}

	if !stop {
		n.applyWeight(offset, depth+1, w)
	}
}
