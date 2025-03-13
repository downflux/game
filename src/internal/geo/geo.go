package geo

import (
	"math"

	"graphics.gd/variant/Vector2"
	"graphics.gd/variant/Vector2i"
)

var (
	CellSize   = Vector2.XY{32, 16}
	CellOffset = Vector2.MulX(CellSize, 0.5)
)

func ToGrid(world Vector2.XY) Vector2i.XY {
	return Vector2i.XY{
		int32(math.Round(float64((world.X - 2.0*world.Y) / CellSize.X))),
		int32(math.Round(float64((world.X + 2.0*world.Y - CellSize.X) / CellSize.X))),
	}
}

func ToWorld(grid Vector2i.XY) Vector2.XY {
	return Vector2.XY{
		CellOffset.X*float32(grid.Y+grid.X) + CellOffset.X,
		CellOffset.Y*float32(grid.Y-grid.X) + CellOffset.Y,
	}
}
