package potential_map

import (
	"fmt"
	"math/rand"
	"reflect"
	"testing"

	"graphics.gd/variant/Rect2i"
	"graphics.gd/variant/Vector2i"
)

func TestApplyWeight(t *testing.T) {
	for _, c := range []struct {
		name        string
		attenuation float64
		region      Rect2i.PositionSize
		offset      Vector2i.XY
		w           int
		want        [][]int
	}{
		{
			name:        "NoTransmission",
			attenuation: 0,
			region: Rect2i.PositionSize{
				Position: Vector2i.XY{0, 0},
				Size:     Vector2i.XY{2, 2},
			},
			offset: Vector2i.XY{0, 0},
			w:      255,
			want: [][]int{
				[]int{255, 0},
				[]int{0, 0},
			},
		},
		{
			name:        "FullTransmission",
			attenuation: 1,
			region: Rect2i.PositionSize{
				Position: Vector2i.XY{0, 0},
				Size:     Vector2i.XY{2, 2},
			},
			offset: Vector2i.XY{0, 0},
			w:      255,
			want: [][]int{
				[]int{255, 255},
				[]int{255, 255},
			},
		},
	} {
		t.Run(c.name, func(t *testing.T) {
			n := &N{Attenuation: c.attenuation}
			n.SetRegion(c.region)
			n.applyWeight(c.offset, 0, c.w)
			if !reflect.DeepEqual(n.weights, c.want) {
				t.Errorf("n.weights = %v, want = %v", n.weights, c.want)
			}
		})
	}

}

func BenchmarkSetPointWeight(b *testing.B) {
	_max := 255
	for _, d := range []int32{100, 200, 400, 8000} {
		for _, a := range []float64{0.0, 0.25, 0.5} {
			b.Run(fmt.Sprintf("D=%v/A=%v", d, a), func(b *testing.B) {
				node := &N{Attenuation: a}
				node.SetRegion(Rect2i.PositionSize{
					Position: Vector2i.XY{0, 0},
					Size:     Vector2i.XY{int32(d), int32(d)},
				})
				for n := 0; n < b.N; n++ {
					node.SetPointWeight(Vector2i.XY{rand.Int31n(d), rand.Int31n(d)}, _max)
				}
			})
		}
	}
}
