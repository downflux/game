package example

import (
	"fmt"

	"grow.graphics/gd"
)

type N struct {
	gd.Class[N, gd.Node2D] `gd:"DFExampleNode"`
}

func (n *N) Ready() {
	fmt.Printf("the Example node is ready\n")
}

func (n *N) Foo() {
	fmt.Printf("calling test function Foo\n")
