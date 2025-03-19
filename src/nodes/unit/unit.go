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

	mover *walker.N
}

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

func (n *N) Get(k string) any {
	if k == "position" {
		if n.mover != nil {
			return geo.ToGrid(n.mover.Data().Position())
		}
	}
	return nil
}

func (n *N) Set(k string, v any) bool {
	if k == "position" {
		if n.mover != nil {
			if p, ok := v.(Vector2i.XY); ok {
				n.mover.SetPath([]mover.M[walker.T]{
					{
						Position: geo.ToWorld(p),
						MoveType: walker.MoveTypeTeleport,
					},
				})
				return true
			}
		}
		return false
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
