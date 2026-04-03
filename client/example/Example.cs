using System;

public partial class Example : Godot.Node2D
{
	public Example() {
		Godot.GD.Print("Hello World");
		Curve<int> x = new();
		Godot.GD.Print(x.Value(Godot.Time.GetTicksMsec()));
	}
}

public class Curve<T> where T : struct {
	public Nullable<T> Value(ulong t) {
		return default(T);
	}
}
