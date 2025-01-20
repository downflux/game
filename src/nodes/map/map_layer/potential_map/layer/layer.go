// Package layer applies a scalar field over a 2D grid.
//
// This field is comprised of sources and sinks which decay in a set manner and
// represents the tendency towards a specific path in the grid.
package layer

import (
	"math"

	"graphics.gd"
)

type O struct {
	// Attenuation is a number in the range [0, 1). This designates how
	// strongly any source influence will fade over the map.
	Attenuation float64
}

type L struct {
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

func New(o O) *L {
	l := &L{
		Attenuation: o.Attenuation
	}
	l.Clear()
	return l
}

func (l *L) Clear() {
	l.SetRegion(gd.Rect2i{Position: gd.Vector2i{0, 0}, Size: gd.Vector2i{0, 0}})
}

// SetRegion preps the node for subsequent use. This must be called before
// calling SetPointWeight.
func (l *L) SetRegion(r gd.Rect2i) {
	l.region = gd.Rect2i{
		Position: r.Position,
		Size:     r.Size,
	}
	l.sources = [][]int{}
	l.weights = [][]int{}
	for i := int64(0); i < r.Size.X(); i++ {
		l.sources = append(l.sources, make([]int, r.Size.Y()))
		l.weights = append(l.weights, make([]int, r.Size.Y()))
	}
}

func (l *L) GetRegion() gd.Rect2i { return l.region }

func (l *L) SetPointWeight(id gd.Vector2i, w int) gd.Error {
	if !l.region.HasPoint(id) {
		return gd.ErrParameterRangeError
	}

	offset := id.Sub(l.region.Position)
	l.applyWeight(offset, 0, -l.sources[offset.X()][offset.Y()])
	l.sources[offset.X()][offset.Y()] = w
	l.applyWeight(offset, 0, w)

	return gd.Ok
}

// applyWeight implements a BFS over the 2D grid and sets some attenuated value
// over the different boarders.
func (l *L) applyWeight(offset gd.Vector2i, depth int32, w int) {
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
		if l.region.HasPoint(c) {
			l := c.Sub(offset).Length()
			w := math.Floor(float64(w) * math.Pow(l.Attenuation, l))
			if w > 0 {
				stop = false
				l.weights[c.X()][c.Y()] += int(w)
			}
		}
	}

	if !stop {
		l.applyWeight(offset, depth+1, w)
	}
}
