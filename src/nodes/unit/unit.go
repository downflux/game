package unit

import (
	"github.com/downflux/gd-game/internal/geo"
	"graphics.gd/classdb"
	"graphics.gd/classdb/Node2D"
	"graphics.gd/classdb/Tween"
	"graphics.gd/variant/Object"
	"graphics.gd/variant/Vector2i"
	"graphics.gd/variant/Vector2"
)

type MoveState int

const (
	MoveStateInvalid MoveState = iota
	MoveStateIdle
	MoveStateArrived
	MoveStateWalk
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

	if geo.ToWorld(n.head) != n.Super().AsNode2D().Position() {
		n.smove = MoveStateWalk
	} else {
		if len(n.tail) == 0 {
			n.smove = MoveStateIdle
		} else {
			n.smove = MoveStateArrived
		}
	}
	return n.smove
}

func (n *N) move() {
	if n.MoveState() == MoveStateWalk || n.MoveState() == MoveStateIdle {
		return
	}

	n.head, n.tail = n.tail[0], n.tail[1:]
	n.invalidateMoveState()

	dt := Vector2.Length(Vector2.Sub(n.Super().AsNode2D().Position(), geo.ToWorld(n.head))) / n.Speed

	n.tmove = n.Super().AsNode().CreateTween()
	n.tmove.SetProcessMode(Tween.TweenProcessPhysics)
	n.tmove.TweenProperty(
		n.AsObject(), "position", geo.ToWorld(n.head), dt,
	)
	n.tmove.TweenCallback(n.invalidateMoveState)
	n.tmove.Play()
}

func (n *N) Ready() {
	n.Speed = 32

	n.Super().SetPosition(geo.ToWorld(Vector2i.XY{0, 0}))
	n.head = n.Grid()
}

func (n *N) Process(d float32) {
	Object.Use(n.tmove)

	n.move()
}
