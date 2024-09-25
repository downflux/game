package main

import (
	"github.com/downflux/gd-game/nodes/example"
	"grow.graphics/gd"
	"grow.graphics/gd/gdextension"
)

func main() {
	godot, ok := gdextension.Link()
	if !ok {
		return
	}
	gd.Register[example.T](godot)
	gd.Register[example.N](godot)
}
