package fsm

import (
	"fmt"
)

type FSM[T ~int] struct {
	valid bool
	cache T

	Transitions map[T]map[T]bool
}

func New[T ~int](ts map[T]map[T]bool) *FSM[T] {
	return &FSM[T]{
		Transitions: ts,
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

	if possible, ok := m.Transitions[m.cache]; ok {
		if _, ok := possible[s]; ok {
			m.cache = s
			return nil
		}
	}
	return fmt.Errorf("invalid transition: %v -> %v", T(m.cache), T(s))
}
