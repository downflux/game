package walker

import (
	"fmt"

	"github.com/downflux/gd-game/internal/data/mover"
	"github.com/downflux/gd-game/internal/fsm/walk"
	"graphics.gd/classdb"
	"graphics.gd/classdb/Node"
	"graphics.gd/classdb/Tween"
	"graphics.gd/variant/Object"
	"graphics.gd/variant/Vector2"
)

type T int

const (
	MoveTypeUnknown T = iota
	MoveTypeWalk
	MoveTypeTeleport
)

type N struct {
	classdb.Extension[N, Node.Instance]

	Speed float32

	mover *mover.N[T]
	tween Tween.Instance

	fsm *walk.FSM
}

func (n *N) Ready() {
	n.mover = mover.New[T]()
	n.fsm = walk.New()
}

func (n *N) AppendPath(path []mover.M[T]) {
	tail := n.mover.Tail()
	n.SetPath(append(tail, path...))
}

func (n *N) Data() *mover.N[T] { return n.mover }

func (n *N) SetPath(path []mover.M[T]) {
	n.mover.SetPath(path)

	if len(n.mover.Tail()) > 0 {
		if s := n.fsm.State(); s == walk.StateIdle || s == walk.StateUnknown {
			if err := n.fsm.SetState(walk.StateCheckpoint); err != nil {
				panic(err)
			}
		}
	}
}

func (n *N) Visit(d *mover.N[T]) error {
	switch s := n.fsm.State(); s {
	case walk.StateUnknown:
		fallthrough
	case walk.StateTransit:
		fallthrough
	case walk.StateIdle:
		return nil
	case walk.StateCheckpoint:
		if len(n.mover.Tail()) == 0 {
			return n.fsm.SetState(walk.StateIdle)
		}

		if err := n.fsm.SetState(walk.StateTransit); err != nil {
			return err
		}

		head := n.mover.Tail()[0]
		n.mover.SetPath(n.mover.Tail()[1:])

		dt := float32(0)
		if head.MoveType == MoveTypeWalk {
			dt = Vector2.Length(
				Vector2.Sub(
					n.mover.Position(),
					head.Position,
				),
			) / n.Speed
		}

		n.tween = n.Super().AsNode().CreateTween()
		n.tween.SetProcessMode(Tween.TweenProcessPhysics)
		n.tween.TweenMethod(
			func(v any) {
				n.mover.SetPosition(v.(Vector2.XY))
			},
			n.mover.Position(),
			head.Position,
			dt,
		)
		n.tween.TweenCallback(func() {
			if err := n.fsm.SetState(walk.StateCheckpoint); err != nil {
				panic(err)
			}
		})
		n.tween.Play()
		return nil
	default:
		return fmt.Errorf("invalid state encountered: %v", s)
	}
}

func (n *N) Process(d float32) {
	Object.Use(n.tween)

	if err := n.Visit(n.mover); err != nil {
		panic(err)
	}
}
