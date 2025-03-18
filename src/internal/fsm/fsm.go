package fsm

import (
	"fmt"
)

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

type FSM[T ~int] struct {
	valid bool
	cache T

	transitions map[T]map[T]bool
}

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

func (m *FSM[T]) Invalidate() { m.valid = false }

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
		return nil
	}

	if possible, ok := m.transitions[m.cache]; ok {
		if _, ok := possible[s]; ok {
			m.cache = s
			return nil
		}
	}
	return fmt.Errorf("invalid transition: %v -> %v", T(m.cache), T(s))
}
