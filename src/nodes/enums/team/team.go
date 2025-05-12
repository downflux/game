package team

import (
	"graphics.gd/variant/Enum"
)

type T Enum.Int[struct {
	Unknown T `gd:"TEAM_UNKNOWN"`
	Neutral T `gd:"TEAM_NEUTRAL"`
	A       T `gd:"TEAM_A"`
	B       T `gd:"TEAM_B"`
}]

var Teams = Enum.Values[T]()
