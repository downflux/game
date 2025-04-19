package unit

import (
	"fmt"

	"github.com/downflux/gd-game/internal/components/walker"
	"github.com/downflux/gd-game/internal/data/mover"
	"github.com/downflux/gd-game/internal/fsm/walk"
	"github.com/downflux/gd-game/internal/geo"
	"graphics.gd/classdb"
	"graphics.gd/classdb/Node2D"
	"graphics.gd/variant/Callable"
	"graphics.gd/variant/Vector2i"
)

// f is a function to be attached to a signal.
//
// Attach via
//
//	n.mover.FSM().Signal().Attach(f)
var f = Callable.New(func(s any) {
	fmt.Printf("DEBUG(unit.go): f: Attached FSM state transition received trigger %v\n", s.(walk.S).String())
})

type N struct {
	classdb.Extension[N, Node2D.Instance] `gd:"DFUnit"`

	Debug    bool
	Priority int

	// mover signifies that this unit is a ground / seaborne unit. This
	// node does not animate flight.
	mover *walker.N
}

// Move instructs the unit to move through a series of TileMapLayer cells.
func (n *N) Move(path []Vector2i.XY) {
	h := n.mover.Data().Head().Position
	ps := []mover.M[walker.T]{}
	for _, p := range path {
		ps = append(ps, mover.M[walker.T]{
			Position: geo.ToWorld(p),
			MoveType: walker.MoveTypeWalk,
		})
	}
	if n.Debug {
		fmt.Printf("DEBUG(unit.go): Move: (head, tail) = (%v, %v)\n", h, ps)
	}
	n.mover.SetPath(ps)
}

// GetPathSource returns the TileMapLayer cell from which the caller must use
// when query for a path. This cell may be different from the actual current
// position of the unit.
//
// Consider the case where a unit is in position X and with head (i.e. currently
// animated towards a destination) Y != X. The caller will logically attempt to
// set a path using the current node's position X. The path generated from this
// query may be of the form [X, Y, Z, ...] -- that is to say, the unit will move
// back to X after its current animation is finished.
func (n *N) GetPathSource() Vector2i.XY {
	if n.mover != nil {
		return geo.ToGrid(n.mover.Data().Head().Position)
	}
	return Vector2i.XY{}
}

// Get overrides the native node.position query and returns the cell position of
// the node.
//
// N.B.:
//
//	Object.Advanced(n.Super().AsObject()).AsObject()
//
// does not expose the internal.Object.Get() base method. We must manually
// handle all property sets in this case.
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
	case "debug":
		return n.Debug
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
	case "debug":
		if d, ok := v.(bool); ok {
			n.Debug = d
		}
	}
	return true
}

func (n *N) Ready() {
	n.mover = &walker.N{
		Speed: 32,
	}
	n.Super().AsNode().AddChild(n.mover.Super().AsNode())
	if n.Debug {
		n.mover.FSM().Signal().Attach(f)
	}
}

func (n *N) Process(d float32) {
	n.Super().AsNode2D().SetPosition(n.mover.Data().Position())
}
