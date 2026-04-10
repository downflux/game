using Godot;
using System;
using System.Collections.Generic;
using System.Collections;
using System.Linq;

namespace DF.Lib;

public enum InterpolationType {
	Linear,
	Step,
	// TODO(minkezhang): Implement Pulse type.
	// Pulse,
}

public partial class CurveNode<T> : Node where T : struct {
	private Curve<T> curve = new();
}

public record struct Snapshot<T>(ulong Timestamp, T Value) where T : struct;

public class Curve<T> where T : struct {
	private SortedList<ulong, T> schedule = new();
	private List<(ulong Timestamp, T? Value)> schedule_cache = new();
	private InterpolationType interpolation_type = InterpolationType.Linear;
	
	public Curve(InterpolationType t = InterpolationType.Linear) {
		this.interpolation_type = t;
	}
	
	// Returns (K, V) tuple at the given index. This index must exist in the
	// schedule.
	private Snapshot<T> GetSnapshot(int index) => new (
		this.schedule.GetKeyAtIndex(index),
		this.schedule.GetValueAtIndex(index));
	
	/// <summary>
	/// Get a timestamp which is guaranteed to have an associated value lower than
	/// or equal to the input timestamp.
	/// </summary>
	/// <summary>
	/// The input timestamp may lie in between tween points. If this is the case,
	/// return the smallest timestamp which has a definitive associated value. If
	/// the input timestamp already exists as a defined key in the tween, return
	/// the timestamp.
	/// </summary>
	/// <returns>
	/// The (K, V) tuple of lower bound. The timestamp of this tuple is guaranteed
	/// to exist in the curve. Returns null if the input timestamp is less than
	/// the first defined point.
	/// </returns>
	public Snapshot<T>? LowerBound(ulong timestamp) {
		if (!this.schedule.Any()) {
			return null;
		}
		
		(int lo, int hi) = (0, this.schedule.Count - 1);
		while (lo <= hi) {
			int mid = lo + (hi - lo) / 2;
			if (timestamp == this.schedule.GetKeyAtIndex(mid)) {
				return this.GetSnapshot(mid);
			} else if (timestamp < this.schedule.GetKeyAtIndex(mid)) {
				if (mid - 1 >= 0 && this.schedule.GetKeyAtIndex(mid - 1) < timestamp) { // mid - 1 < v < mid
					return this.GetSnapshot(mid - 1);
				} else {
					hi = mid - 1;
				}
			} else {
				lo = mid + 1;
			}
		}
		
		if (hi < 0) {  // mid = -1
			return null;
		}
		
		return this.GetSnapshot(hi);  // mid = this.snapshot.Count - 1
	}
	
	public Snapshot<T>? UpperBound(ulong timestamp) {
		if (!this.schedule.Any()) {
			return null;
		}
		
		var lower = this.LowerBound(timestamp);
		if (!lower.HasValue) {
			return this.GetSnapshot(0);
		} else if(lower.Value.Timestamp == timestamp) {
			return lower;
		} else {
			var index = this.schedule.IndexOfKey(lower.Value.Timestamp);
			if (index < this.schedule.Count - 1) {
				return this.GetSnapshot(index + 1);
			}
		}
		
		return null;
	}
	
	/// <summary>
	/// Remove all data strictly after the input timestamp.
	/// </summary>
	public void Trim(ulong t) {
		var lower = this.LowerBound(t);
		var index = lower.HasValue ? this.schedule.IndexOfKey(lower.Value.Timestamp) : -1;
		for (var i = index + 1; i <= this.schedule.Count - 1; i++) {
			this.schedule_cache.Add((this.schedule.GetKeyAtIndex(i), null));
		}
	}
	
	/// <summary>
	/// Merges data strictly after some time t. Assumes data at t is valid, but
	/// all values after t is invalid. If a timestamp is not provided, replace the
	/// schedule with the input.
	/// </summary>
	public void Merge(ulong? t, List<Snapshot<T>> data) {
		// Trim data if t is present.
		if (t.HasValue) {
			var lower = this.LowerBound(t.Value);
			if (lower.HasValue) {
				this.schedule_cache.Add((t.Value, lower.Value.Value));
			}
			this.Trim(t.Value);
		} else {
			// Reset the schedule if no timestamp is provided.
			foreach (var x in this.schedule) {
				this.schedule_cache.Add((x.Key, null));
			}
		}
		foreach (var x in data.Where(x => (t.HasValue && x.Timestamp > t) || (!t.HasValue))) {  // Only update data after the input timestamp.
			this.schedule_cache.Add((x.Timestamp, x.Value));
		}
	}
	
	public void Schedule(ulong t, T? v) => this.schedule_cache.Add((t, v));
	
	private Snapshot<U> _GetLinear<U>(Snapshot<U> lo, Snapshot<U> hi, ulong t, float dt) where U : struct {
		throw new ArgumentException($"Unsupported Linear interpolation data type {typeof(U)}");
	}
	
	private Snapshot<Godot.Vector2> _GetLinear(
		Snapshot<Godot.Vector2> lo,
		Snapshot<Godot.Vector2> hi,
		ulong t,
		float dt) {
		return new Snapshot<Godot.Vector2>(
			t,
			new(
				lo.Value.X + (hi.Value.X - lo.Value.X) * dt,
				lo.Value.Y + (hi.Value.Y - lo.Value.Y) * dt));
	}
	
	private Snapshot<Godot.Vector3> _GetLinear(
		Snapshot<Godot.Vector3> lo,
		Snapshot<Godot.Vector3> hi,
		ulong t,
		float dt) {
		return new Snapshot<Godot.Vector3>(
			t,
			new(
				lo.Value.X + (hi.Value.X - lo.Value.X) * dt,
				lo.Value.Y + (hi.Value.Y - lo.Value.Y) * dt,
				lo.Value.Z + (hi.Value.Z - lo.Value.Z) * dt));
	}
	
	private Snapshot<float> _GetLinear(Snapshot<float> lo, Snapshot<float> hi, ulong t, float dt) {
		return new Snapshot<float>(t, lo.Value + (hi.Value - lo.Value) * dt);
	}
	
	private Snapshot<ulong> _GetLinear(Snapshot<ulong> lo, Snapshot<ulong> hi, ulong t, float dt) {
		return new Snapshot<ulong>(t, (ulong) System.Math.Round(lo.Value + (hi.Value - lo.Value) * dt));
	}
	
	private Snapshot<int> _GetLinear(Snapshot<int> lo, Snapshot<int> hi, ulong t, float dt) {
		return new Snapshot<int>(t, (int) System.Math.Round(lo.Value + (hi.Value - lo.Value) * dt));
	}
	
	/// <summary>
	/// Returns the interpolated value at the given timestamp. Returns null if the
	/// timestamp is before the first defined point.
	/// </summary>
	public Snapshot<T>? Get(ulong t) {
		var (lo, hi) = (this.LowerBound(t), this.UpperBound(t));
		if (lo.HasValue) {
			if (!hi.HasValue) {
				return new Snapshot<T>(t, lo.Value.Value);
			} else {
				switch (this.interpolation_type) {
					case InterpolationType.Linear:
						if (hi.Value.Timestamp == lo.Value.Timestamp) {
							return lo.Value;
						}
						// Using (dynamic) is necessary to break out into the correct
						// generic types, but is slow. If performance becomes an issue,
						// consider reusing the inline method in
						// https://github.com/downflux/game/commit/a480ef085f56573781dadc1023c5ae69786a4a27.
						//
						// See https://stackoverflow.com/a/3678769 for more information.
						float dt = (
							(float) (t - lo.Value.Timestamp)) / (
							(float) (hi.Value.Timestamp - lo.Value.Timestamp));
						return this._GetLinear((dynamic) lo.Value, (dynamic) hi.Value, t, dt);
					case InterpolationType.Step:
						return new Snapshot<T>(t, lo.Value.Value);
					default:
						break;
				}
			}
		}
		return null;
	}
	
	/// <summary>
	/// Flush the Curve schedule_cache and commit to the schedule.
	/// </summary>
	public void Flush() {
		if (!this.schedule_cache.Any()) {  // is_dirty = False
			return;
		}
		
		foreach(var e in this.schedule_cache) {
			if (this.schedule.ContainsKey(e.Timestamp)) {
				// If a value already exists at the target timestamp, overwrite with new value.
				if (e.Value.HasValue) {
					this.schedule.SetValueAtIndex(this.schedule.IndexOfKey(e.Timestamp), e.Value.Value);
				} else {
					this.schedule.Remove(e.Timestamp);
				}
			} else if (e.Value.HasValue) {
				this.schedule.Add(e.Timestamp, e.Value.Value);
			}
		}
		
		this.schedule_cache.Clear();
	}
	
	public List<Snapshot<T>>? GetSlice((ulong? Lo, ulong? Hi) interval) {
		if (!this.schedule.Any()) {
			return null;
		}
		
		var lo = this.UpperBound(
			interval.Lo.HasValue ? interval.Lo.Value : this.schedule.GetKeyAtIndex(0));
		var hi = this.LowerBound(
			interval.Hi.HasValue ? interval.Hi.Value : this.schedule.GetKeyAtIndex(this.schedule.Count - 1));
		
		if (!lo.HasValue || !hi.HasValue) { return null; }  // Should not happen.
		
		var res = new List<Snapshot<T>>();
		
		if (interval.Lo.HasValue && interval.Lo.Value != lo.Value.Timestamp) {
			var s = this.Get(interval.Lo.Value);
			if (s.HasValue) {
				res.Add(s.Value);
			}
		}
		
		for(var i = this.schedule.IndexOfKey(lo.Value.Timestamp); i <= this.schedule.IndexOfKey(hi.Value.Timestamp); i++) {
			res.Add(this.GetSnapshot(i));
		}
		
		if (interval.Hi.HasValue && interval.Hi.Value != hi.Value.Timestamp) {
			var s = this.Get(interval.Hi.Value);
			if (s.HasValue) {
				res.Add(s.Value);
			}
		}
		
		return res;
	}
	
	public void Clear() {
		foreach(var (k, v) in this.schedule) {
			this.schedule_cache.Add((k, null));
		}
	}
}
