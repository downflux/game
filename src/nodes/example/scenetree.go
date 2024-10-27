package example

import (
	"fmt"

	"grow.graphics/gd"
)

// T is a custom SceneTree.
//
// Per https://pkg.go.dev/grow.graphics/gd#Register, calling gd.Register for a
// struct extending gd.SceneTree will ensure the custom struct will be used as
// the main loop.
type T struct {
	gd.Class[T, gd.SceneTree] `gd:"DFExampleSceneTree"`
}

// Initialize implements the Godot MainLoop _initialize interface (virtual function).
func (h *T) Initialize() {
	fmt.Println("The Example SceneTree is initialized")
}
