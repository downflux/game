package fsm

import (
	"testing"
)

type S int

const (
	StateUnknown S = iota
	StateOpen
	StateClosed
	StateInvalid
)

var (
	transitions = ToEdgeCache(
		[]E[S]{
			{Source: StateOpen, Destination: StateClosed},
		},
	)
)

func TestSetState(t *testing.T) {
	t.Run("Valid", func(t *testing.T) {
		m := &FSM[S]{
			valid:       true,
			cache:       StateOpen,
			transitions: transitions,
		}
		if err := m.SetState(StateClosed); err != nil {
			t.Errorf("SetState() returned a non-nil error: %v", err)
		}
	})

	t.Run("Invalid", func(t *testing.T) {
		n := &FSM[S]{
			valid:       true,
			cache:       StateClosed,
			transitions: transitions,
		}
		if err := n.SetState(StateOpen); err == nil {
			t.Errorf("SetState() unexpectedly succeded")
		}
	})
}
