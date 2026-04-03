using Godot;
using System;

public partial class Example : Node2D
{
	public Example() {
		GD.Print("Hello World");
		Curve<int> x = new();
		GD.Print(x.Value(100));
	}
}

public class Curve<T> where T : struct {
	public Nullable<T> Value(int t) {
		return default(T);
	}
}
