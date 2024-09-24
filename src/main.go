// This file is all you need to start a project in Go + Godot.
// Save it somewhere, install the `gd` command and use `gd run` to get started.
package main

import (
	"fmt"

	"grow.graphics/gd"
	"grow.graphics/gd/gdextension"
)

type Test struct {
  gd.Class[Test, gd.Node2D]
}

func (h *Test) Ready() {
  fmt.Println("Hello from Test")
}

type HelloWorld struct {
	gd.Class[HelloWorld, gd.SceneTree]
}

// Initialize implements the Godot MainLoop _initialize interface (virtual function).
func (h *HelloWorld) Initialize() {
	fmt.Println("Hello World from Go!")
}

func main() {
	godot, ok := gdextension.Link()
	if !ok {
		return
	}
	gd.Register[HelloWorld](godot)
        gd.Register[Test](godot)
}
