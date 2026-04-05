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

enum InterpolationType {
	Linear
	Step
	Pulse
}

public partial class TweenCurve<T> : Godot.Node where T: struct {
	public delegate ulong GetTimeDelegate();
	
	private 
	private SortedList<ulong, T> schedule = new();
	private List<(ulong Target, ulong? Source, T Value)> schedule_cache = new();
	
	private GetTimeDelegate timer;  // Get the current time.
	
	public TweenCurve(GetTimeDelegate f) {
		this.timer = f;
	}
	
	public TweenCurve() : this(() => Godot.Time.GetTicksMsec()) {
	}
	
	public void Halt() => this.Truncate(this.timer() /* set behavior */ )
	public void Truncate(ulong t /* stop behavior or hard truncate */) {}
	public T? Get(ulong t) { return default(T); } // TODO(minkezhang): implmement
	
	// Update the Curve schedule.
	public override void _Process(double delta) {
		if (!this.schedule_cache.Any()) { return; }  // is_dirty = False
		
		foreach(var e in this.schedule_cache) {
			// If this value is a move op, update the key.
			if (e.Source.HasValue && this.schedule.ContainsKey(e.Source.Value)) {
				this.schedule.Remove(e.Source.Value);
			}
			
			// If a value already exists at the target timestamp, overwrite with new
			// value.
			if (this.schedule.ContainsKey(e.Target)) {
				this.schedule.Remove(e.Target);
			}
			this.schedule.Add(e.Target, e.Value);
		}
		
		this.schedule_cache.Clear();
	}
}

public class Curve<T> where T : struct {
	private Dictionary<ulong, T> data = new();
	private List<ulong> timestamps = new();
	private T default_value = default(T);
	
	private List<(ulong Timestamp, T Value)> set_ops = new();
	private List<(ulong Timestamp, double Delay)> shift_ops = new();
	
	public Curve() : this(default(T)) {
	}
	
	public Curve(T default_value) : this(new Dictionary<ulong, T>(), default(T)){
	}
	
	public Curve(Dictionary<ulong, T> data, T default_value) {
		this.default_value = default_value;
		this.data = data.ToDictionary(e => e.Key, e => e.Value);
	}
	
	public void Set(ulong t, T v) {
		this.set_ops.Add((t, v));
	}
	
	public void Shift(ulong t, double delay) {
		this.shift_ops.Add((t, delay));
	}
	
	public Nullable<T> Get(ulong t, double delta) {
		return default(T);
	}
	
	public void _Process(double delta) {
		this.set_ops.ForEach(x => this.data[x.Timestamp] = x.Value);
		this.set_ops.ForEach(x => this.timestamps.Add(x.Timestamp));
		this.set_ops.Clear();
		this.timestamps.Sort();
	}
}
