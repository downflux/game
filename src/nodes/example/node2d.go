package example

import (
	"fmt"

	"graphics.gd/classdb"
	"graphics.gd/classdb/Node2D"
)

type N struct {
	classdb.Extension[N, Node2D.Instance] `gd:"DFExampleNode"`
}

func (n *N) Ready() {
	fmt.Printf("the Example node is ready\n")
}

func (n *N) Foo() {
	fmt.Printf("calling test function Foo\n")
}
