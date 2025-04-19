package directory

import (
	"graphics.gd/variant/Vector2i"
)

type U interface {
	Position() Vector2i.XY
}

type D struct {
	lookup map[int]map[int][]U
	dim Vector2i.XY
}

func New(dim Vector2i.XY
