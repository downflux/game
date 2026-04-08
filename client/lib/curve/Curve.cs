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
	
	public Snapshot<T>? Get(ulong t) {
		var (lo, hi) = (this.LowerBound(t), this.UpperBound(t));
		if (lo.HasValue) {
			if (!hi.HasValue) {
				return new Snapshot<T>(t, lo.Value.Value);
			} else {
				float scale_factor = ((float) (t - lo.Value.Timestamp)) / ((float) (hi.Value.Timestamp - lo.Value.Timestamp));
				switch (this.interpolation_type) {
					case InterpolationType.Linear:
						switch (typeof(T)) {
							case Type type when (type == typeof(ulong)):
								(ulong? v_hi_ulong, ulong? v_lo_ulong) = (hi.Value.Value as ulong?, lo.Value.Value as ulong?);
								if (!v_hi_ulong.HasValue || !v_lo_ulong.HasValue) {
									return null;
								}
								T? val_ulong = (ulong) System.Math.Round(
									(float) v_lo_ulong.Value + (((float) v_hi_ulong.Value - (float) v_lo_ulong.Value) * scale_factor)) as T?;
								if (!val_ulong.HasValue) {
									return null;
								}
								return new Snapshot<T>(t, val_ulong.Value);
							case Type type when (type == typeof(int)):
								(int? v_hi_int, int? v_lo_int) = (hi.Value.Value as int?, lo.Value.Value as int?);
								if (!v_hi_int.HasValue || !v_lo_int.HasValue) {
									return null;
								}
								T? val_int = (int) System.Math.Round(
									(float) v_lo_int.Value + (((float) v_hi_int.Value - (float) v_lo_int.Value) * scale_factor)) as T?;
								if (!val_int.HasValue) {
									return null;
								}
								return new Snapshot<T>(t, val_int.Value);
							case Type type when (type == typeof(float)):
								(float? v_hi_float, float? v_lo_float) = (hi.Value.Value as float?, lo.Value.Value as float?);
								if (!v_hi_float.HasValue || !v_lo_float.HasValue) {
									return null;
								}
								T? val_float = (v_lo_float.Value + ((v_hi_float.Value - v_lo_float.Value) * scale_factor)) as T?;
								if (!val_float.HasValue) {
									return null;
								}
								return new Snapshot<T>(t, val_float.Value);
							default:
								return null;
						}
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
