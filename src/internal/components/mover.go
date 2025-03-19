package mover

import (
	"fmt"

	"github.com/downflux/gd-game/internal/components/mover/data"
	"github.com/downflux/gd-game/internal/fsm/move/amphibious"
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

	data  *data.N[T]
	tween Tween.Instance

	fsm *amphibious.FSM
}

func (n *N) Ready() {
	n.data = data.New[T]()
	n.fsm = amphibious.New()
}

func (n *N) AppendPath(path []data.M[T]) {
	tail := n.data.Tail()
	n.SetPath(append(tail, path...))
}

func (n *N) Data() *data.N[T] { return n.data }

func (n *N) SetPath(path []data.M[T]) {
	n.data.SetPath(path)

	if len(n.data.Tail()) > 0 {
		if s := n.fsm.State(); s == amphibious.StateIdle || s == amphibious.StateUnknown {
			if err := n.fsm.SetState(amphibious.StateCheckpoint); err != nil {
				panic(err)
			}
		}
	}
}

func (n *N) Visit(d *data.N[T]) error {
	switch s := n.fsm.State(); s {
	case amphibious.StateUnknown:
		fallthrough
	case amphibious.StateTransit:
		fallthrough
	case amphibious.StateIdle:
		return nil
	case amphibious.StateCheckpoint:
		if len(n.data.Tail()) == 0 {
			return n.fsm.SetState(amphibious.StateIdle)
		}

		if err := n.fsm.SetState(amphibious.StateTransit); err != nil {
			return err
		}

		head := n.data.Tail()[0]
		n.data.SetPath(n.data.Tail()[1:])

		dt := float32(0)
		if head.MoveType == MoveTypeWalk {
			dt = Vector2.Length(
				Vector2.Sub(
					n.data.Position(),
					head.Position,
				),
			) / n.Speed
		}

		n.tween = n.Super().AsNode().CreateTween()
		n.tween.SetProcessMode(Tween.TweenProcessPhysics)
		n.tween.TweenMethod(
			func(v any) {
				n.data.SetPosition(v.(Vector2.XY))
			},
			n.data.Position(),
			head.Position,
			dt,
		)
		n.tween.TweenCallback(func() {
			if err := n.fsm.SetState(amphibious.StateCheckpoint); err != nil {
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

	if err := n.Visit(n.data); err != nil {
		panic(err)
	}
}
