package example

import (
	"fmt"

	"grow.graphics/gd"
)

type N struct {
	gd.Class[N, gd.Node2D] `gd:"DownFluxExampleNode"`
}

func (n *N) Ready() {
	fmt.Println("The Example node is ready")
}
