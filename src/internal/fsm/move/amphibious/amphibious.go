package amphibious

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
	transitions = fsm.ToEdgeCache(
		[]fsm.E[S]{
			fsm.E[S]{Source: StateIdle, Destination: StateCheckpoint},
			fsm.E[S]{Source: StateTransit, Destination: StateCheckpoint},
			fsm.E[S]{Source: StateCheckpoint, Destination: StateIdle},
			fsm.E[S]{Source: StateCheckpoint, Destination: StateTransit},
		},
	)
)

type FSM struct {
	*fsm.FSM[S]
}

func New() *FSM {
	return &FSM{
		fsm.New[S](fsm.O[S]{Transitions: transitions}),
	}
}
