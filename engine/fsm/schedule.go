package schedule

import (
	"sync"

	"github.com/downflux/game/engine/fsm/action"
	"github.com/downflux/game/engine/fsm/list"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"

	fcpb "github.com/downflux/game/engine/fsm/api/constants_go_proto"
)

type Schedule struct {
	fsmTypes map[fcpb.FSMType]bool

	mux     sync.Mutex
	actions map[fcpb.FSMType]*list.List
}

func New(fsmTypes []fcpb.FSMType) *Schedule {
	s := &Schedule{
		fsmTypes: map[fcpb.FSMType]bool{},
	}
	for _, fsmType := range fsmTypes {
		s.fsmTypes[fsmType] = true
	}
	return s
}

func (s *Schedule) Pop() *Schedule {
	s.mux.Lock()
	defer s.mux.Unlock()

	ns := &Schedule{
		actions:  s.actions,
		fsmTypes: s.fsmTypes,
	}
	s.actions = nil
	return ns
}

func (s *Schedule) addUnsafe(i action.Action) error {
	if s.actions == nil {
		s.actions = map[fcpb.FSMType]*list.List{}
	}

	fsmType := i.Type()

	if !s.fsmTypes[fsmType] {
		return status.Errorf(codes.FailedPrecondition, "schedule does not accept %v FSM actions", fsmType)
	}

	if _, found := s.actions[fsmType]; !found {
		s.actions[fsmType] = list.New(fsmType)
	}

	return s.actions[fsmType].Add(i)
}

func (s *Schedule) Extend(actions []action.Action) error {
	s.mux.Lock()
	defer s.mux.Unlock()

	for _, i := range actions {
		if err := s.addUnsafe(i); err != nil {
			return err
		}
	}
	return nil
}

// Merge replaces the internal FSMs with FSMs of higher priority.
func (s *Schedule) Merge(t *Schedule) error {
	s.mux.Lock()
	defer s.mux.Unlock()

	if s.actions == nil {
		s.actions = map[fcpb.FSMType]*list.List{}
	}

	// TODO(minkezhang): Consider if we should make this parallel.
	for fsmType := range s.fsmTypes {
		if l := t.Get(fsmType); l != nil {
			if _, found := s.actions[fsmType]; !found {
				s.actions[fsmType] = list.New(fsmType)
			}

			if err := s.actions[fsmType].Merge(l); err != nil {
				return err
			}
		}
	}
	return nil
}

// TODO(minkezhang): Rename List.
func (s *Schedule) Get(fsmType fcpb.FSMType) *list.List {
	s.mux.Lock()
	defer s.mux.Unlock()

	if s.actions == nil {
		s.actions = map[fcpb.FSMType]*list.List{}
	}

	if _, found := s.actions[fsmType]; !found {
		s.actions[fsmType] = list.New(fsmType)
	}

	return s.actions[fsmType]
}

func (s *Schedule) Clear() error {
	s.mux.Lock()
	defer s.mux.Unlock()

	for _, l := range s.actions {
		if err := l.Clear(); err != nil {
			return err
		}
	}
	return nil
}
