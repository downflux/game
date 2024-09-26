package level

import (
	"grow.graphics/gd"
)

type N struct {
	gd.Class[N, gd.Node3D] `gd:"DFLevel"`

	Camera  gd.Camera3D
	Terrain gd.GridMap
}

func (n *N) Ready() {
	n.Camera.SetProjection(gd.Camera3DProjectionOrthogonal)
}
