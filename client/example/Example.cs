using System;
using System.Collections.Generic;
using System.Collections;
using System.Linq;

public partial class Example : Godot.Node2D
{
	public Example() {
		Godot.GD.Print("Hello World");
		Curve<int> x = new();
		Godot.GD.Print(x.Get(Godot.Time.GetTicksMsec(), 30));
	}
	public override void _Process(double delta) {
	}
}

public class Curve<T> where T : struct {
	private Dictionary<ulong, T> data = new();
	private Dictionary<ulong, T> write_cache = new();
	private List<ulong> timestamps = new();
	private T default_value = default(T);
	
	public Curve() : this(default(T)) {
	}
	
	public Curve(T default_value) : this(new Dictionary<ulong, T>(), default(T)){
	}
	
	public Curve(Dictionary<ulong, T> data, T default_value) {
		this.default_value = default_value;
		this.data = data.ToDictionary(e => e.Key, e => e.Value);
	}
	
	public void Set(ulong t, T v) {
		this.write_cache[t] = v;
	}
	
	public Nullable<T> Get(ulong t, double delta) {
		return default(T);
	}
	
	public void _Process(double delta) {
		this.write_cache.ToList().ForEach(x => this.data[x.Key] = x.Value);
		this.write_cache.ToList().ForEach(x => this.timestamps.Add(x.Key));
		this.write_cache.Clear();
		this.timestamps.Sort();
	}
}
