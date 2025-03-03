package pathfinder

import (
	"math"
	"math/rand"

	"graphics.gd/classdb"
	"graphics.gd/classdb/AStarGrid2D"
	"graphics.gd/classdb/Node"
	"graphics.gd/variant/Array"
	"graphics.gd/variant/Enum"
	"graphics.gd/variant/Object"
	"graphics.gd/variant/Rect2i"
	"graphics.gd/variant/Vector2"
	"graphics.gd/variant/Vector2i"
)

type L Enum.Int[struct {
	Unknown L `gd:"LAYER_UNKNOWN"`
	Ground  L `gd:"LAYER_GROUND"`
	Air     L `gd:"LAYER_AIR"`
	Sea     L `gd:"LAYER_SEA"`
}]

var Layers = Enum.Values[L]()

type N struct {
	classdb.Extension[N, Node.Instance] `gd:"DFNavigation"`

	DebugLayer L
	layers     map[L]AStarGrid2D.Instance
}

func (n *N) Ready() {
	n.layers = map[L]AStarGrid2D.Instance{
		Layers.Ground: AStarGrid2D.New(),
		Layers.Air:    AStarGrid2D.New(),
		Layers.Sea:    AStarGrid2D.New(),
	}

	for _, g := range n.layers {
		g.SetCellShape(AStarGrid2D.CellShapeIsometricRight)
		g.SetCellSize(Vector2.XY{32, 16})
		g.SetDiagonalMode(AStarGrid2D.DiagonalModeAtLeastOneWalkable)
		g.Update()
	}
}

func (n *N) Process(d float32) {
	for _, g := range n.layers {
		Object.Use(g)
	}
}

func (n *N) SetPointSolid(ls []L, id Vector2i.XY, v bool) {
	for _, k := range ls {
		if l, ok := n.layers[k]; ok {
			AStarGrid2D.Advanced(l).SetPointSolid(id, v)
		}
	}
}

// FillSolidRegion sets a region of the pathing tilemap as vacant or blocked.
//
// This is called during run-time when buildings are added or destroyed.
//
// N.B.: This pathing struct does not track history -- the caller is responsible
// for restoring the pathing tilemap to its original state, e.g. in the case
// that the underlying region was not empty when calling
//
//	FillSolidRegion(layers, r, true)
func (n *N) FillSolidRegion(ls []L, r Rect2i.PositionSize, v bool) {
	for _, k := range ls {
		if l, ok := n.layers[k]; ok {
			AStarGrid2D.Advanced(l).FillSolidRegion(r, v)
		}
	}
}

func (n *N) SetRegion(r Rect2i.PositionSize) {
	for _, g := range n.layers {
		g.SetRegion(r)
		g.Update()
		g.FillSolidRegion(r)
	}
}

// bfs searches the associated map layer for the nearest open cell.
//
// If there are multiple candidates, bfs will return the cell which minimizes
// the given heuristic function
//
//	func(id Vector2i) float32
//
// If there is no open cell, bfs returns the original input.
func (n *N) bfs(k L, id Vector2i.XY, h func(id Vector2i.XY) float32) Vector2i.XY {
	l, ok := n.layers[k]
	if !ok {
		return id
	}

	open := []Vector2i.XY{id}
	candidate := id
	success := false
	offset := int32(0)

	m := AStarGrid2D.New()
	m.SetCellShape(AStarGrid2D.CellShapeIsometricRight)
	m.SetCellSize(Vector2.XY{32, 16})
	m.SetDiagonalMode(AStarGrid2D.DiagonalModeAtLeastOneWalkable)
	m.Update()

	for !success && len(open) > 0 {
		cost := math.Inf(1)
		for _, c := range open {
			if l.IsInBoundsv(c) && !l.IsPointSolid(c) {
				success = true
				if g := float64(h(c)); g < cost {
					cost = g
					candidate = c
				}
			}
		}

		if !success {
			open = nil
			offset += 1
			c := Vector2i.XY{}
			for dx := int32(-offset); dx <= offset; dx++ {
				c.X = id.X + dx
				c.Y = id.Y - offset

				if l.IsInBoundsv(c) {
					open = append(open, c)
				}

				c.Y = id.Y + offset

				if l.IsInBoundsv(c) {
					open = append(open, c)
				}
			}
			if offset > 2 {
				for dy := int32(-offset) + 1; dy <= offset-1; dy++ {
					c.X = id.X + offset
					c.Y = id.Y + dy

					if l.IsInBoundsv(c) {
						open = append(open, c)
					}

					c.X = id.X - offset

					if l.IsInBoundsv(c) {
						open = append(open, c)
					}
				}
			}

			// Shuffle border list.
			for i := range open {
				j := rand.Intn(i + 1)
				open[i], open[j] = open[j], open[i]
			}
		}
	}

	return candidate
}

func (n *N) GetIDPath(k L, src Vector2i.XY, dst Vector2i.XY, allowPartialPath bool) Array.Contains[Vector2i.XY] {
	l, ok := n.layers[k]
	if !ok {
		return Array.New[Vector2i.XY]()
	}

	h := func(id Vector2i.XY) float32 { return Vector2i.LengthSquared(Vector2i.Sub(src, id)) }

	return AStarGrid2D.Advanced(l).GetIdPath(
		Vector2i.XY(n.bfs(k, src, h)),
		Vector2i.XY(n.bfs(k, dst, h)),
		allowPartialPath,
	)
}
