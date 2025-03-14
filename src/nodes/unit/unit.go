package unit

import (
	"fmt"

	"github.com/downflux/gd-game/internal/geo"
	"graphics.gd/classdb"
	"graphics.gd/classdb/Node2D"
	"graphics.gd/classdb/Tween"
	"graphics.gd/variant"
	"graphics.gd/variant/Object"
	"graphics.gd/variant/Vector2"
	"graphics.gd/variant/Vector2i"
)

type MoveState int

const (
	MoveStateInvalid MoveState = iota
	MoveStateIdle
	MoveStateCheckpoint
	MoveStateTransit
)

type N struct {
	classdb.Extension[N, Node2D.Instance] `gd:"DFUnit"`

	Speed float32

	head  Vector2i.XY
	tail  []Vector2i.XY
	tmove Tween.Instance
	smove MoveState
}

func (n *N) Grid() Vector2i.XY { return geo.ToGrid(n.Super().AsNode2D().Position()) }

func (n *N) SetPath(path []Vector2i.XY) {
	n.tail = path
	n.invalidateMoveState()
}

func (n *N) AppendPath(path []Vector2i.XY) {
	n.tail = append(n.tail, path...)
	n.invalidateMoveState()
}

func (n *N) invalidateMoveState() { n.smove = MoveStateInvalid }

func (n *N) MoveState() MoveState {
	if n.smove != MoveStateInvalid {
		return n.smove
	}

	if n.tmove != Tween.Nil && n.tmove.IsValid() {
		n.smove = MoveStateTransit
	} else if geo.ToWorld(n.head) != n.Super().AsNode2D().Position() {
		n.smove = MoveStateTransit
	} else if len(n.tail) == 0 {
		n.smove = MoveStateIdle
	} else {
		n.smove = MoveStateCheckpoint
	}
	return n.smove
}

func (n *N) Set(k string, v any) bool {
	if k == "position" {
		n.Super().AsNode2D().SetPosition(variant.As[Vector2.XY](variant.New(v)))
	}
	return true
}

/*func (n *N) Position() Vector2.XY {
	return Vector2.XY{0, 0}
}
*/

func (n *N) move() {
	if n.MoveState() == MoveStateTransit || n.MoveState() == MoveStateIdle {
		return
	}

	n.head, n.tail = n.tail[0], n.tail[1:]
	n.invalidateMoveState()

	dv := Vector2i.Length(
		Vector2i.Sub(
			n.Grid(),
			n.head,
		),
	)

	dt := dv / n.Speed

	n.tmove = n.Super().AsNode().CreateTween()
	n.tmove.SetProcessMode(Tween.TweenProcessPhysics)
	n.tmove.TweenProperty(
		n.AsObject(), "position", geo.ToWorld(n.head), dt,
	)
	n.tmove.TweenCallback(n.invalidateMoveState)
	n.tmove.Play()
}

func (n *N) teleport() {
}

func (n *N) Ready() {
	n.Speed = 1

	n.Super().SetPosition(geo.ToWorld(Vector2i.XY{0, 0}))
	n.head = n.Grid()
}

func (n *N) Process(d float32) {
	Object.Use(n.tmove)

	n.move()
}
