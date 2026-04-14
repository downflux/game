using System;
using System.Collections.Generic;
using System.Linq;

namespace DF.Lib.Tween;

public enum InterpolationType {
	Linear,
	Step,
	// TODO(minkezhang): Implement Pulse type.
	// Pulse,
}

/// <summary>
/// A structured tuple representing a vertical slice of a <see cref="Tween" />
/// at a specific point in time.
/// </summary>
/// <typeparam name="U">
/// The value of the tween at this associated timestamp.
/// </typeparam>
/// <typeparam name="W">
/// Optional associated data stored at this timestamp. This data is not used
/// for value comparison, and may be e.g. a delegate (i.e. a trigger).
/// </typeparam>
/// <param name="T">
/// Timestamp of the frame in milliseconds since the start of the program.
/// </param>
/// <param name="V">Value of the frame, e.g. a <c>bool</c> or
/// <c><see cref="Godot.Vector2" /></c>.
/// </param>
/// <param name="D">Additional metadata, e.g. delegates.</param>
public record struct Frame<U, W>(
	ulong T,  // Timestamp
	U V,      // Value
	W? D      // Data
)
	where U : struct
	where W : struct;

public class Tween<U, W>
	where U : struct
	where W : struct
{
	/// <summary>
	/// The internal list of tween keyframes which is used to interpolate data at
	/// any given timestamp (given as milliseconds since the start of the
	/// program). This property is only mutated with explicit calls to
	/// <see cref="Tween{U, W}.Flush"> list.
	/// </summary>
	private SortedList<ulong, Frame<U, W>> _keyframes = new();
	
	/// <summary>
	/// The set of keyframe buffers which needs to be written to the internal
	/// <see cref="Tween{U, W}._keyframes"> list.
	/// </summary>
	private List<(ulong T, Frame<U, W>? F)> _buf = new();
	
	private InterpolationType _interpolation_type;
	
	public Tween(InterpolationType t) => this._interpolation_type = t;
	
	/// <summary>
	/// Get an explicit keyframe stored in the tween which is guaranteed to have
	/// occurred at or before the input timestamp.
	/// </summary>
	/// <remarks>
	/// If the input timestamp lie between keyframes, return the most recent
	/// keyframe which occurs before the input. If the input timestamp is before
	/// the first explicit keyframe, return <c>null</c>.
	/// </remarks>
	internal Frame<U, W>? LowerBound(ulong t)
	{
		if (!this._keyframes.Any())
		{
			return null;
		}
		
		(int lo, int hi) = (0, this._keyframes.Count - 1);
		while (lo <= hi)
		{
			int mid = lo + (hi - lo) / 2;
			if (t == this._keyframes.GetKeyAtIndex(mid))
			{
				return this._keyframes.GetValueAtIndex(mid);
			}
			else if (t < this._keyframes.GetKeyAtIndex(mid))
			{
				// mid - 1 < v < mid
				if (mid - 1 >= 0 && this._keyframes.GetKeyAtIndex(mid - 1) < t)
				{
					return this._keyframes.GetValueAtIndex(mid - 1);
				}
				else
				{
					hi = mid - 1;
				}
			}
			else
			{
				lo = mid + 1;
			}
		}
		
		// mid = -1
		if (hi < 0)
		{ 
			return null;
		}
		
		return this._keyframes.GetValueAtIndex(hi);  // mid = this._keyframes.Count - 1
	}
	
	/// <summary>
	/// Get an explicit keyframe stored in the tween which is guaranteed to have
	/// occurred at or after the input timestamp. c.f.
	/// <see cref="Tween{U, W}.LowerBound">.
	/// </summary>
	internal Frame<U, W>? UpperBound(ulong t)
	{
		if (!this._keyframes.Any())
		{
			return null;
		}
		
		var lb = this.LowerBound(t);
		if (!lb.HasValue) {
			return this._keyframes.GetValueAtIndex(0);
		}
		else if(lb.Value.T == t)
		{
			return lb;
		}
		else
		{
			var index = this._keyframes.IndexOfKey(lb.Value.T);
			if (index < this._keyframes.Count - 1)
			{
				return this._keyframes.GetValueAtIndex(index + 1);
			}
		}
		
		return null;
	}
	
	private U InterpolateLinear(U lo, U hi, float dt)
	{
		throw new ArgumentException($"Unsupported Linear interpolation data type {typeof(U)}");
	}
	
	private Godot.Vector2 InterpolateLinear(
		Godot.Vector2 lo,
		Godot.Vector2 hi,
		float dt) => new(
			lo.X + (hi.X - lo.X) * dt,
			lo.Y + (hi.Y - lo.Y) * dt);
	
	private Godot.Vector3 InterpolateLinear(
		Godot.Vector3 lo,
		Godot.Vector3 hi,
		float dt) => new(
			lo.X + (hi.X - lo.X) * dt,
			lo.Y + (hi.Y - lo.Y) * dt,
			lo.Z + (hi.Z - lo.Z) * dt);
	
	private float InterpolateLinear(
		float lo,
		float hi,
		float dt) => lo + (hi - lo) * dt;
	
	/// <summary>
	/// Schedules adding <i>or updating</i> a frame to the tween.
	/// </summary>
	public void Add(List<Frame<U, W>> fs) => fs.ForEach(f => this._buf.Add((f.T, f)));
	
	/// <summary>
	/// Returns the interpolated tween frame at the given timestamp. Returns null
	/// if the timestamp is before the first defined point.
	/// </summary>
	public Frame<U, W>? Get(ulong t)
	{
		(Frame<U, W>? lb, Frame<U, W>? ub) = (this.LowerBound(t), this.UpperBound(t));
		if (lb.HasValue) {
			// t lies on an explicit keyframe.
			if (t == lb.Value.T)
			{
				return lb;
			}
			// t lies beyond the last known explicit keyframe -- the tween should
			// pause at the last known value.
			else if (!ub.HasValue)
			{
				return new Frame<U, W>(t, lb.Value.V, null);
			}
			else
			{
				switch (this._interpolation_type)
				{
					case InterpolationType.Linear:
						if (ub.Value.T == lb.Value.T)
						{
							return lb.Value;
						}
						// Using (dynamic) is necessary to break out into the correct
						// generic types, but is slow. If performance becomes an issue,
						// consider reusing the inline method in
						// https://github.com/downflux/game/commit/a480ef085f56573781dadc1023c5ae69786a4a27.
						//
						// See https://stackoverflow.com/a/3678769 for more information.
						float dt = (
							(float) (t - lb.Value.T)) / (
							(float) (ub.Value.T - lb.Value.T));
						return new Frame<U, W>(
							t,
							this.InterpolateLinear(
								(dynamic) lb.Value.V,
								(dynamic) ub.Value.V,
								dt),
							null);
					case InterpolationType.Step:
						return new Frame<U, W>(t, lb.Value.V, null);
					default:
						break;
				}
			}
		}
		return null;
	}
	
	/// <summary>
	/// Get a list of frames in this tween.
	/// </summary>
	/// <remarks>
	/// Returns all frames in between <c>lo <= t <= hi</c>. If the interval bounds
	/// <c>lo</c> and <c>hi</c> are not a keyframe, return the interpolated frame
	/// at the given bounds as well.
	/// </remarks>
	public List<Frame<U, W>> Slice(ulong? lo, ulong? hi)
	{
		var slice = new List<Frame<U, W>>();
		
		if (!this._keyframes.Any())
		{
			return slice;
		}
		
		Frame<U, W>? lb = this.UpperBound(
			lo.HasValue ? lo.Value : this._keyframes.GetKeyAtIndex(0));
		Frame<U, W>? ub = this.LowerBound(
			hi.HasValue ? hi.Value : this._keyframes.GetKeyAtIndex(
				this._keyframes.Count - 1));
		
		if (!lb.HasValue || !ub.HasValue)  // Should not happen.
		{
			return slice;
		}
		
		if (lo.HasValue && lo.Value != lb.Value.T)
		{
			Frame<U, W>? f = this.Get(lo.Value);
			if (f.HasValue)
			{
				slice.Add(f.Value);
			}
		}
		
		for(
			var i = this._keyframes.IndexOfKey(lb.Value.T);
			i <= this._keyframes.IndexOfKey(ub.Value.T);
			i++)
		{
			slice.Add(this._keyframes.GetValueAtIndex(i));
		}
		
		if (hi.HasValue && hi.Value != ub.Value.T)
		{
			Frame<U, W>? f = this.Get(hi.Value);
			if (f.HasValue)
			{
				slice.Add(f.Value);
			}
		}
		
		return slice;
	}
	
	public void Merge() {}
	
	/// <summary>
	/// Commits all writes to <see cref="Tween._buf"> to the internal
	/// <see cref="Tween._keyframes"> list.
	/// </summary>
	public void Flush()
	{
		foreach(var e in this._buf) {
			if (this._keyframes.ContainsKey(e.T)) {
				// If a value already exists at the target timestamp, overwrite with new value.
				if (e.F.HasValue) {
					this._keyframes.SetValueAtIndex(this._keyframes.IndexOfKey(e.T), e.F.Value);
				} else {
					this._keyframes.Remove(e.T);
				}
			} else if (e.F.HasValue) {
				this._keyframes.Add(e.T, e.F.Value);
			}
		}
		
		this._buf.Clear();
	}
	
	/// <summary>
	/// Schedules all keyframes in the tween for deletion.
	/// </summary>
	public void Clear() {}
}
