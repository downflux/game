using Godot;
using System;

public partial class Example : Node2D
{
	public Example() {
		GD.Print("Hello World");
		Downflux.Lib.Curve<int> x = new();
		GD.Print(x.Get(Time.GetTicksMsec()));
	}
	
	public override void _Process(double delta) {
	}
}
