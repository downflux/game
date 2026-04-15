using Godot;
using System;

public partial class Example : Node2D
{
	public Example() {
		var t = new DF.Lib.Tween.Tween<float, bool>(
			DF.Lib.Tween.InterpolationType.Linear);
		GD.Print(t.Get(Time.GetTicksMsec()));
	}
	
	public override void _Process(double delta) {
	}
}
