package move

import (
	"github.com/downflux/gd-game/internal/fsm"
)

type S int

const (
	StateUnknown S = iota
	StateIdle
	StateCheckpoint
	StateTransit
)

var (
	t = []fsm.E[S]{
		fsm.E[S]{Source: StateIdle, Destination: StateCheckpoint},
		fsm.E[S]{Source: StateTransit, Destination: StateCheckpoint},
		fsm.E[S]{Source: StateCheckpoint, Destination: StateIdle},
		fsm.E[S]{Source: StateCheckpoint, Destination: StateTransit},
	}
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
	*fsm.FSM[S]
}

func New() *FSM {
	return &FSM{
		fsm.New[S](fsm.O[S]{Transitions: t}), // transitions),
	}
}
