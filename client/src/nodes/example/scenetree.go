package example

import (
	"fmt"

	"graphics.gd/classdb"
	"graphics.gd/classdb/SceneTree"
)

// T is a custom SceneTree.
//
// Per https://pkg.go.dev/grow.graphics/gd#Register, calling gd.Register for a
// struct extending gd.SceneTree will ensure the custom struct will be used as
// the main loop.
type T struct {
	classdb.Extension[T, SceneTree.Instance] `gd:"DFExampleSceneTree"`
}

// Initialize implements the Godot MainLoop _initialize interface (virtual function).
func (h *T) Initialize() {
	fmt.Println("The Example SceneTree is initialized")
}
