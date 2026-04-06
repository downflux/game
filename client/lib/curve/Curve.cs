using Godot;
using System;
using System.Collections.Generic;
using System.Collections;
using System.Linq;

namespace Downflux.Lib;

enum InterpolationType {
	Linear,
	Step,
	Pulse,
}

public partial class Curve<T> : Node where T: struct {
	/* Type Declarations */
	public delegate ulong GetTimeDelegate();
	public record struct Value(ulong T, T V);
	
	private SortedList<ulong, T> schedule = new();
	private List<(ulong Target, ulong? Source, T Value)> schedule_cache = new();
	
	private GetTimeDelegate timer;  // Get the current time.
	
	public Curve(GetTimeDelegate f) {
		this.timer = f;
	}
	
	public Curve() : this(() => Time.GetTicksMsec()) {
	}
	
	// Returns the bounded interval indices of the sorted list of timestamps.
	private static (int? Lo, int? ID, int? Hi) BinarySearch(IList<ulong> l, ulong v) {
		(int lo, int hi) = (0, l.Count - 1);
		while (lo <= hi) {  // binary search
			int mid = lo + (hi - lo) / 2;
			if (v == l[mid]) {
				return (null, mid, null);
			}
			else if (v < l[mid]) {  // mid - 1 < v < mid
				if (mid - 1 >= 0 && l[mid - 1] < v) {
					return (mid - 1, null, mid);
				}
				hi = mid - 1;
			}
			else {  // mid < v < mid + 1
				if (mid + 1 <= l.Count - 1 && v < l[mid - 1]) {
					return (mid, null, mid + 1);
				}
				lo = mid + 1;
			}
		}
		return (null, null, null);
	}
	
	public (Value? Lo, Value? V, Value? Hi) GetInterval(ulong timestamp) {
		var bounds = Curve<T>.BinarySearch(this.schedule.Keys, timestamp);
		return (
			bounds.Lo.HasValue ? new Curve<T>.Value(
				this.schedule.GetKeyAtIndex(bounds.Lo.Value),
				this.schedule.GetValueAtIndex(bounds.Lo.Value)) : null,
			bounds.ID.HasValue ? new Curve<T>.Value(
				this.schedule.GetKeyAtIndex(bounds.ID.Value),
				this.schedule.GetValueAtIndex(bounds.ID.Value)) : null,
			bounds.Hi.HasValue ? new Curve<T>.Value(
				this.schedule.GetKeyAtIndex(bounds.Hi.Value),
				this.schedule.GetValueAtIndex(bounds.Hi.Value)) : null);
	}
	
	public void Halt() => this.Truncate(this.timer(), false);
	public void Truncate(ulong t, bool keep) {
	/*
		int i = this.schedule.
		if keep {
			
		}
		*/
	}
	
	public void Schedule(ulong t, ulong? s, T v) => this.schedule_cache.Add((t, s, v));
	
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
