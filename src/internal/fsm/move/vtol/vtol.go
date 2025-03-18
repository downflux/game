package vtol

import (
	"github.com/downflux/gd-game/internal/fsm"
)

type S int

const (
	StateUnknown S = iota
	StateIdle
	StateTakeoff
	StateLanding
	StateHover
	StateCheckpoint
	StateTransit
)

var (
	eNoAllowLandings = []fsm.E[S]{
		{Source: StateIdle, Destination: StateTakeoff},
		{Source: StateTakeoff, Destination: StateHover},
		{Source: StateHover, Destination: StateTransit},
		{Source: StateTransit, Destination: StateCheckpoint},
		{Source: StateCheckpoint, Destination: StateHover},
		{Source: StateCheckpoint, Destination: StateTransit},
		{Source: StateLanding, Destination: StateIdle},
	}
	eAllowLandings = append(eNoAllowLandings, fsm.E[S]{Source: StateHover, Destination: StateLanding})

	tNoAllowLandings = fsm.ToEdgeCache(eNoAllowLandings)
	tAllowLandings   = fsm.ToEdgeCache(eAllowLandings)
)

type O struct {
	AllowLandings bool
}

type FSM struct {
	*fsm.FSM[S]
}

func New(o O) *FSM {
	ts := tNoAllowLandings
	if o.AllowLandings {
		ts = tAllowLandings
	}
	return &FSM{fsm.New[S](fsm.O[S]{Transitions: ts})}
}
