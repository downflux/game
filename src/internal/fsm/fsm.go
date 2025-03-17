package fsm

import (
	"fmt"
)

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
	Transitions []E[T]
}

func New[T ~int](o O[T]) *FSM[T] {
	fsm := &FSM[T]{
		transitions: map[T]map[T]bool{},
	}

	for _, t := range o.Transitions {
		if _, ok := fsm.transitions[t.Source]; !ok {
			fsm.transitions[t.Source] = map[T]bool{}
		}
		fsm.transitions[t.Source][t.Destination] = true
	}

	return fsm
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
