package unit

import (
	"github.com/downflux/gd-game/internal/components/walker"
	"github.com/downflux/gd-game/internal/data/mover"
	"github.com/downflux/gd-game/internal/geo"
	"graphics.gd/classdb"
	"graphics.gd/classdb/Node2D"
	"graphics.gd/variant/Vector2i"
)

type N struct {
	classdb.Extension[N, Node2D.Instance] `gd:"DFUnit"`

	// mover signifies that this unit is a ground / seaborne unit. This
	// node does not animate flight.
	mover *walker.N
}

// Move instructs the unit to move through a series of TileMapLayer cells.
func (n *N) Move(path []Vector2i.XY) {
	ps := []mover.M[walker.T]{}
	for _, p := range path {
		ps = append(ps, mover.M[walker.T]{
			Position: geo.ToWorld(p),
			MoveType: walker.MoveTypeWalk,
		})
	}
	n.mover.SetPath(ps)
}

// Get overrides the native node.position query and returns the cell position of
// the node.
func (n *N) Get(k string) any {
	switch k {
	case "position":
		if n.mover != nil {
			return geo.ToGrid(n.mover.Data().Position())
		}
	case "speed":
		if n.mover != nil {
			return n.mover.Speed
		}
	}

	return nil
}

// Set overrides the native node.position mutate operation and instead instructs
// the unit to teleport to the given tile cell after the current movement tween
// finishes.
func (n *N) Set(k string, v any) bool {
	switch k {
	case "position":
		if n.mover == nil {
			return false
		}
		if p, ok := v.(Vector2i.XY); ok {
			n.mover.SetPath([]mover.M[walker.T]{
				{
					Position: geo.ToWorld(p),
					MoveType: walker.MoveTypeTeleport,
				},
			})
		}
	case "speed":
		if n.mover == nil {
			return false
		}
		if s, ok := v.(int64); ok {
			n.mover.Speed = int(s)
		}
	}
	return true
}

func (n *N) Ready() {
	n.mover = &walker.N{
		Speed: 32,
	}
	n.Super().AsNode().AddChild(n.mover.Super().AsNode())
}

func (n *N) Process(d float32) {
	n.Super().AsNode2D().SetPosition(n.mover.Data().Position())
}
