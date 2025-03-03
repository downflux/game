package geo

import (
	"graphics.gd/variant/Vector2"
	"graphics.gd/variant/Vector2i"
)

var (
	CellSize   = Vector2.XY{32, 16}
	CellOffset = Vector2.MulX(CellSize, 0.5)
)

func ToGrid(world Vector2.XY) Vector2i.XY {
	grid := Vector2.Floor(Vector2.Div(world, CellSize))
	return Vector2i.XY{int32(grid.X), int32(grid.Y)}
}

func ToWorld(grid Vector2i.XY) Vector2.XY {
	return Vector2.Add(
		Vector2.Mul(
			Vector2.XY{float32(grid.X), float32(grid.Y)},
			CellSize,
		),
		CellOffset,
	)
}
