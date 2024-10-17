package tile

import (
	"grow.graphics/gd"
)

type N struct {
	gd.Class[N, gd.Node2D] `gd:"DFTile"`

	Texture         gd.PackedScene
	GroundCollision gd.PackedScene

	t  gd.Sprite2D
	cg gd.CollisionPolygon2D
	Z  gd.Int
}

func (n *N) Ready() {
	if (n.Texture == gd.PackedScene{}) {
		n.Temporary.PushError(n.Temporary.Variant(
			n.Temporary.String("empty Texture PackedScene"),
		))
		return
	} else {
		var ok bool
		n.t, ok = gd.As[gd.Sprite2D](
			n.Temporary,
			n.Texture.Instantiate(
				n.Temporary,
				gd.PackedSceneGenEditStateDisabled,
			),
		)
		if !ok {
			n.Temporary.PushError(n.Temporary.Variant(
				n.Temporary.String("Texture must be of type Sprite2D"),
			))
			return
		}
	}

	if (n.GroundCollision == gd.PackedScene{}) {
		n.Temporary.PushError(n.Temporary.Variant(
			n.Temporary.String("empty GroundCollision PackedScene"),
		))
		return
	} else {
		var ok bool
		n.cg, ok = gd.As[gd.CollisionPolygon2D](
			n.Temporary, n.GroundCollision.Instantiate(
				n.Temporary,
				gd.PackedSceneGenEditStateDisabled,
			),
		)
		if !ok {
			n.Temporary.PushError(n.Temporary.Variant(
				n.Temporary.String("GroundCollision must be of type CollisionShape2D"),
			))
			return
		}
	}
}
