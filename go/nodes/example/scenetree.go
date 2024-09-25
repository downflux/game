package example

import (
	"fmt"

	"grow.graphics/gd"
)

type T struct {
	gd.Class[T, gd.SceneTree] `gd:"DownFluxExampleSceneTree"`
}

// Initialize implements the Godot MainLoop _initialize interface (virtual function).
func (h *T) Initialize() {
	fmt.Println("The Example SceneTree is initialized")
}
