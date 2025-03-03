// Package example provides some trivial example Godot nodes.
//
// These nodes document ways in which the GDExtension layer API interacts with
// Golang.
//
// The DFExampleNode may be instantiated by creating a "DFExampleNode" instance
// in the Godot UI. A script may be attached to this instance, e.g.
//
//	extends DFExampleNode
//
//	func _ready():
//	  simple_function()
//	  # _hidden_function()  # Not accessible from GDScript.
//
// Note the naming differences here. graphics.gd automatically converts naming
// conventions between GDScript and Golang.
package example

import (
	"fmt"

	"graphics.gd/classdb"
	"graphics.gd/classdb/Node2D"
)

type DFExampleNode struct {
	classdb.Extension[DFExampleNode, Node2D.Instance]
}

func (n *DFExampleNode) Ready() {
	fmt.Printf("the Example node is ready\n")
}

func (n *DFExampleNode) _HiddenFunction() {
	fmt.Printf("calling hidden function _HiddenFunction\n")
}

// Foo is a sample function which checks for calls from the child class.
func (n *DFExampleNode) SimpleFunction() {
	fmt.Printf("calling test function SimpleFunction\n")
	n._HiddenFunction()
}
