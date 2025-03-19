package mover

import (
	"graphics.gd/variant/Vector2"
)

type M[T ~int] struct {
	Position Vector2.XY
	MoveType T
}

type N[T ~int] struct {
	position Vector2.XY

	head M[T]
	tail []M[T]
}

type V[T ~int] interface {
	Visit(n *N[T]) error
}

func New[T ~int]() *N[T] {
	return &N[T]{}
}

func (n *N[T]) Position() Vector2.XY     { return n.position }
func (n *N[T]) SetPosition(p Vector2.XY) { n.position = p }

func (n *N[T]) Head() M[T]   { return n.head }
func (n *N[T]) Tail() []M[T] { return n.tail }

func (n *N[T]) SetPath(path []M[T]) { n.tail = append([]M[T]{}, path...) }

func (n *N[T]) Accept(v V[T]) error { return v.Visit(n) }
