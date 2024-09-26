package main

import (
	"github.com/downflux/gd-game/nodes/example"
	"github.com/downflux/gd-game/nodes/level"
	"grow.graphics/gd"
	"grow.graphics/gd/gdextension"
)

func main() {
	godot, ok := gdextension.Link()
	if !ok {
		return
	}

	gd.Register[level.N](godot)
	gd.Register[example.N](godot)
}
