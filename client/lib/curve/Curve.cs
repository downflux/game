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

public partial class CurveNode<T> : Node where T : struct {
	private Curve<T> curve = new();
}

public record struct Snapshot<T>(ulong Timestamp, T Value) where T : struct;
public record struct Interval<T>(Snapshot<T>? Lo, Snapshot<T>? Hi) where T : struct;

public class Curve<T> where T : struct {
	private SortedList<ulong, T> schedule = new();
	private List<(ulong Target, ulong? Source, T Value)> schedule_cache = new();
	
	private InterpolationType interpolation_type = InterpolationType.Linear;
	
	private Snapshot<T> GetSnapshot(int index) => new (
		this.schedule.GetKeyAtIndex(index),
		this.schedule.GetValueAtIndex(index));
	
	/// <summary>
	/// Get a timestamp which is guaranteed to have an associated value.
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
		
		if (hi <= 0) {  // mid = -1
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
	
	/*
	public void Halt() => this.Truncate(this.timer(), false);
	public void Truncate(ulong t, bool keep) {
		int i = this.schedule.
		if keep {
			
		}
	}
	 */
	
	public void Schedule(ulong t, ulong? s, T v) => this.schedule_cache.Add((t, s, v));
	
	public Snapshot<U> _GetLinear<U>(Snapshot<U> lo, Snapshot<U> hi, ulong t, float dt) where U : struct {
		throw new ArgumentException($"Unsupported Linear interpolation data type {typeof(U)}");
	}
	
	public Snapshot<float> _GetLinear(Snapshot<float> lo, Snapshot<float> hi, ulong t, float dt) {
		return new Snapshot<float>(t, lo.Value + (hi.Value - lo.Value) * dt);
	}
	
	public Snapshot<ulong> _GetLinear(Snapshot<ulong> lo, Snapshot<ulong> hi, ulong t, float dt) {
		return new Snapshot<ulong>(t, (ulong) System.Math.Round(lo.Value + (hi.Value - lo.Value) * dt));
	}
	
	public Snapshot<int> _GetLinear(Snapshot<int> lo, Snapshot<int> hi, ulong t, float dt) {
		return new Snapshot<int>(t, (int) System.Math.Round(lo.Value + (hi.Value - lo.Value) * dt));
	}
	
	public Snapshot<T>? Get(ulong t) {
		var (lo, hi) = (this.LowerBound(t), this.UpperBound(t));
		if (lo.HasValue) {
			if (!hi.HasValue) {
				return new Snapshot<T>(t, lo.Value.Value);
			} else {
				switch (this.interpolation_type) {
					case InterpolationType.Linear:
						// Using (dynamic) is necessary to break out into the correct generic types, but is
						// slow. If performance becomes an issue, consider reusing the inline method in
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
	
	// Update the Curve schedule.
	public void Process(double delta) {
		if (!this.schedule_cache.Any()) {  // is_dirty = False
			return;
		}
		
		foreach(var e in this.schedule_cache) {
			// If this value is a move op, update the key.
			if (e.Source.HasValue && this.schedule.ContainsKey(e.Source.Value)) {
				this.schedule.Remove(e.Source.Value);
			}
			
			// If a value already exists at the target timestamp, overwrite with new
			// value.
			if (this.schedule.ContainsKey(e.Target)) {
				this.schedule.SetValueAtIndex(this.schedule.IndexOfKey(e.Target), e.Value);
			} else {
				this.schedule.Add(e.Target, e.Value);
			}
		}
		
		this.schedule_cache.Clear();
	}
}
