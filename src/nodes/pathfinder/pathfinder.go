package pathfinder

import (
	"math"
	"math/rand"

	"github.com/downflux/gd-game/internal/geo"
	"github.com/downflux/gd-game/nodes/map/constants/layer"
	"graphics.gd/classdb"
	"graphics.gd/classdb/AStarGrid2D"
	"graphics.gd/classdb/Node"
	"graphics.gd/variant/Array"
	"graphics.gd/variant/Object"
	"graphics.gd/variant/Rect2i"
	"graphics.gd/variant/Vector2i"
)

const (
	CellShape = AStarGrid2D.CellShapeIsometricRight
)

type N struct {
	classdb.Extension[N, Node.Instance] `gd:"DFNavigation"`

	layers map[layer.Bitmask]AStarGrid2D.Instance
}

func (n *N) Ready() {
	n.layers = map[layer.Bitmask]AStarGrid2D.Instance{
		layer.BitmaskGround:     AStarGrid2D.New(),
		layer.BitmaskAir:        AStarGrid2D.New(),
		layer.BitmaskSea:        AStarGrid2D.New(),
		layer.BitmaskAmphibious: AStarGrid2D.New(),
	}

	for k, g := range n.layers {
		g.SetCellShape(CellShape)
		g.SetCellSize(geo.CellSize)

		// Due to the way that the tile sprites are drawn,
		//
		//   L S
		//   S S
		//
		// Diagonally-connected sea tiles (S) which are separated by a
		// land tile (L) do not look like they can be crossed diagonally
		// by ships.
		//
		// This is not the case of the inverse, i.e.
		//
		//   S L
		//   L L
		var mode AStarGrid2D.DiagonalMode
		if k == layer.BitmaskSea {
			mode = AStarGrid2D.DiagonalModeOnlyIfNoObstacles
		} else {
			mode = AStarGrid2D.DiagonalModeAtLeastOneWalkable
		}

		g.SetDiagonalMode(mode)
		g.Update()
	}
}

func (n *N) Process(d float32) {
	// Ensure Godot engine references do not get garbage collected by
	// touching them every frame. See
	// https://github.com/grow-graphics/gd/discussions/84.
	for _, g := range n.layers {
		Object.Use(g)
	}
}

func (n *N) SetPointSolid(l layer.L, id Vector2i.XY, v bool) {
	ml, ok := layer.LToBitmask[l]
	if !ok {
		return
	}

	for k, g := range n.layers {
		if ml&k == k {
			AStarGrid2D.Advanced(g).SetPointSolid(id, v)
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
//	FillSolidRegion(l, r, true)
func (n *N) FillSolidRegion(l layer.L, r Rect2i.PositionSize, v bool) {
	ml, ok := layer.LToBitmask[l]
	if !ok {
		return
	}

	for k, g := range n.layers {
		if ml&k == k {
			AStarGrid2D.Advanced(g).FillSolidRegion(r, v)
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

func neighbors(id Vector2i.XY, offset int32) []Vector2i.XY {
	ns := []Vector2i.XY{}
	for dx := -int32(offset); dx <= offset; dx++ {
		ns = append(ns, Vector2i.XY{id.X + dx, id.Y - offset})
		ns = append(ns, Vector2i.XY{id.X + dx, id.Y + offset})
	}
	for dy := -int32(offset - 1); dy <= offset-1; dy++ {
		ns = append(ns, Vector2i.XY{id.X - offset, id.Y + dy})
		ns = append(ns, Vector2i.XY{id.X + offset, id.Y + dy})
	}
	return ns
}

// bfs searches the associated map layer for the nearest open cell.
//
// If there are multiple candidates, bfs will return the cell which minimizes
// the given heuristic function
//
//	func(id Vector2i) float32
//
// If there is no open cell, bfs returns the original input.
func (n *N) bfs(ml layer.Bitmask, id Vector2i.XY, h func(id Vector2i.XY) float32) Vector2i.XY {
	g, ok := n.layers[ml]
	if !ok {
		return id
	}

	open := []Vector2i.XY{id}
	candidate := id
	success := false
	offset := int32(0)

	for !success && len(open) > 0 {
		cost := math.Inf(1)
		for _, c := range open {
			if g.IsInBoundsv(c) && !g.IsPointSolid(c) {
				success = true
				if f := float64(h(c)); f < cost {
					cost = f
					candidate = c
				}
			}
		}

		if !success {
			offset += 1
			open = neighbors(id, offset)

			// Shuffle border list.
			for i := range open {
				j := rand.Intn(i + 1)
				open[i], open[j] = open[j], open[i]
			}
		}
	}

	return candidate
}

// GetIDPath returns a path from src to dst. If the destination cannot be
// reached from the source due to mismatching terrain types (e.g. ground vs.
// sea), GetIDPath will choose a nearby accessible tile and path to that
// instead. This function also accepts the allow_partial_paths input bool, which
// will return paths in the case that e.g. a wall blocks the path.
func (n *N) GetIDPath(l layer.L, src Vector2i.XY, dst Vector2i.XY, partial bool) Array.Contains[Vector2i.XY] {
	ml, ok := layer.LToBitmask[l]
	if !ok {
		return Array.New[Vector2i.XY]()
	}

	g, ok := n.layers[ml]
	if !ok {
		return Array.New[Vector2i.XY]()
	}

	h := func(id Vector2i.XY) float32 { return Vector2i.LengthSquared(Vector2i.Sub(src, id)) }

	return AStarGrid2D.Advanced(g).GetIdPath(
		Vector2i.XY(n.bfs(ml, src, h)),
		Vector2i.XY(n.bfs(ml, dst, h)),
		partial,
	)
}
