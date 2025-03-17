package move

import (
	"fmt"
)

type S int

const (
	StateUnknown S = iota
	StateIdle
	StateCheckpoint
	StateTransit
)

var (
	transitions = map[S]map[S]bool{
		StateIdle: map[S]bool{
			StateCheckpoint: true,
		},
		StateTransit: map[S]bool{
			StateCheckpoint: true,
		},
		StateCheckpoint: map[S]bool{
			StateIdle:    true,
			StateTransit: true,
		},
	}
)

type FSM struct {
	valid bool
	cache S
}

func New() *FSM { return &FSM{} }

func (m *FSM) Invalidate() { m.valid = false }

func (m *FSM) State() S {
	if !m.valid {
		return StateUnknown
	}
	return m.cache
}

func (m *FSM) SetState(s S) error {
	if m.valid == false {
		m.cache = s
		m.valid = true
		return nil
	}

	if ts, ok := transitions[m.cache]; ok {
		if _, ok := ts[s]; ok {
			m.cache = s
			return nil
		}
	}
	return fmt.Errorf("invalid cache transition: %v -> %v", m.cache, s)
}
