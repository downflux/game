package unit

import (
	"github.com/downflux/gd-game/internal/geo"
	"graphics.gd/classdb"
	"graphics.gd/classdb/Node2D"
	"graphics.gd/classdb/Tween"
	"graphics.gd/variant/Object"
	"graphics.gd/variant/Vector2i"
)

type N struct {
	classdb.Extension[N, Node2D.Instance] `gd:"DFUnit"`

	Path  []Vector2i.XY
	Speed float32

	tmove Tween.Instance
}

func (n *N) Cell() Vector2i.XY {
	return Vector2i.XY{0, 0}
}

func (n *N) move(dst Vector2i.XY) {
	dt := 1 / n.Speed

	n.tmove = n.Super().AsNode().CreateTween()
	n.tmove.SetProcessMode(Tween.TweenProcessPhysics)
	n.tmove.TweenProperty(
		n.AsObject(), "position", geo.ToWorld(dst), dt,
	)
	n.tmove.Play()
}

func (n *N) Ready() {
	n.Speed = 0.5
	n.Super().SetPosition(geo.ToWorld(Vector2i.XY{0, 0}))
	n.move(Vector2i.XY{1, 1})
}

func (n *N) Process(d float32) {
	Object.Use(n.tmove)
}
