package geo

import (
	"graphics.gd/variant/Vector2"
	"graphics.gd/variant/Vector2i"
)

var (
	CellSize   = Vector2.XY{32, 16}
	CellOffset = Vector2.MulX(CellSize, 0.5)

	XOffset = Vector2.XY{CellOffset.X, -CellOffset.Y}
	YOffset = CellOffset
)

func ToGrid(world Vector2.XY) Vector2i.XY {
	grid := Vector2.Round(Vector2.Div(Vector2.Sub(world, CellOffset), CellSize))
	return Vector2i.XY{int32(grid.X), int32(grid.Y)}
}

func ToWorld(grid Vector2i.XY) Vector2.XY {
	return Vector2.Add(
		Vector2.Add(
			Vector2.MulX(XOffset, grid.X),
			Vector2.MulX(YOffset, grid.Y),
		),
		CellOffset,
	)
}
