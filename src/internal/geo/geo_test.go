package geo

import (
	"testing"

	"graphics.gd/variant/Vector2"
	"graphics.gd/variant/Vector2i"
)

func TestToGrid(t *testing.T) {
	for _, c := range []struct {
		name  string
		world Vector2.XY
		want  Vector2i.XY
	}{
		{
			name:  "Trivial",
			world: Vector2.XY{16, 8},
			want:  Vector2i.XY{0, 0},
		},
		{
			name:  "Manual/G=(0,0)",
			world: Vector2.XY{16, 8},
			want:  Vector2i.XY{0, 0},
		},
		{
			name:  "Manual/G=(1,0)",
			world: Vector2.XY{32, 0},
			want:  Vector2i.XY{1, 0},
		},
		{
			name:  "Manual/G=(0,1)",
			world: Vector2.XY{32, 16},
			want:  Vector2i.XY{0, 1},
		},
		{
			name:  "Manual/G=(1,1)",
			world: Vector2.XY{48, 8},
			want:  Vector2i.XY{1, 1},
		},
		{
			name:  "Trivial/Within/Y+",
			world: Vector2.XY{16, 15},
			want:  Vector2i.XY{0, 0},
		},
		{
			name:  "Trivial/Within/Y-",
			world: Vector2.XY{16, 1},
			want:  Vector2i.XY{0, 0},
		},
		{
			name:  "Trivial/Within/X+",
			world: Vector2.XY{31, 8},
			want:  Vector2i.XY{0, 0},
		},
		{
			name:  "Trivial/Within/X-",
			world: Vector2.XY{1, 8},
			want:  Vector2i.XY{0, 0},
		},
		{
			name:  "Adjacent/Diagonal",
			world: Vector2.XY{48, 8},
			want:  Vector2i.XY{1, 1},
		},
	} {
		t.Run(c.name, func(t *testing.T) {
			if got := ToGrid(c.world); got != c.want {
				t.Errorf("ToGrid() = %v, want = %v", got, c.want)
			}
		})
	}
}

func TestToWorld(t *testing.T) {
	for _, c := range []struct {
		name string
		grid Vector2i.XY
		want Vector2.XY
	}{
		{
			name: "Manual/G=(0,0)",
			grid: Vector2i.XY{0, 0},
			want: Vector2.XY{16, 8},
		},
		{
			name: "Manual/G=(1,0)",
			grid: Vector2i.XY{1, 0},
			want: Vector2.XY{32, 0},
		},
		{
			name: "Manual/G=(0,1)",
			grid: Vector2i.XY{0, 1},
			want: Vector2.XY{32, 16},
		},
		{
			name: "Manual/G=(1,1)",
			grid: Vector2i.XY{1, 1},
			want: Vector2.XY{48, 8},
		},
	} {
		t.Run(c.name, func(t *testing.T) {
			if got := ToWorld(c.grid); got != c.want {
				t.Errorf("ToWorld() = %v, want = %v", got, c.want)
			}
		})
	}
}
