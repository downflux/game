// Package fsm defines a finite state machine implementation.
//
// This implementation takes as input a set of valid state transitions and
// allows the internal state to be subsequently changed along valid edges.
package fsm

import (
	"fmt"

	"graphics.gd/variant/Signal"
)

// ToEdgeCache precomputes the adjacency matrix for a set of states.
//
// The adjacency matrix for an FSM will not change -- it is not useful to
// recalculate this structure for every time the FSM is initialized. The caller
// will keep a copy of this cache stored to be set directly in the FSM
// constructor.
func ToEdgeCache[T ~int](edges []E[T]) map[T]map[T]bool {
	transitions := map[T]map[T]bool{}

	for _, e := range edges {
		if _, ok := transitions[e.Source]; !ok {
			transitions[e.Source] = map[T]bool{}
		}
		transitions[e.Source][e.Destination] = true
	}

	return transitions
}

type RO[T ~int] interface {
	State() T
	Signal() *Signal.Solo[T]
}

type FSM[T ~int] struct {
	valid bool
	cache T

	transitions map[T]map[T]bool

	signal Signal.Solo[T]
}

// E is a definition of a valid transition edge.
type E[T ~int] struct {
	Source      T
	Destination T
}

type O[T ~int] struct {
	Transitions map[T]map[T]bool
}

func New[T ~int](o O[T]) *FSM[T] {
	return &FSM[T]{
		transitions: o.Transitions,
	}
}

// Invalidate explicitly sets the state of the FSM as unknown -- this allows
// manually setting the internal state by subsequently calling SetState().
func (m *FSM[T]) Invalidate() {
	m.valid = false
	m.signal.Emit(T(0))
}

func (m *FSM[T]) State() T {
	if !m.valid {
		return T(0)
	}
	return m.cache
}

func (m *FSM[T]) SetState(s T) error {
	if !m.valid {
		m.cache = s
		m.valid = true
		m.signal.Emit(s)
		return nil
	}

	if possible, ok := m.transitions[m.cache]; ok {
		if _, ok := possible[s]; ok {
			m.cache = s
			m.signal.Emit(s)
			return nil
		}
	}
	return fmt.Errorf("invalid transition: %v -> %v", T(m.cache), T(s))
}

func (m *FSM[T]) Signal() *Signal.Solo[T] { return &m.signal }
