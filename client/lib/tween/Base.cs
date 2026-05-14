using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.CodeAnalysis.CSharp.Syntax;

namespace DF.Lib.Tween;

/// <summary>
/// Interface defining a "curve" per
/// <see href="https://www.forrestthewoods.com/blog/tech_of_planetary_annihilation_chrono_cam/" />
/// </summary>
/// <typeparam name="U"></typeparam>
/// <typeparam name="W"></typeparam>
public interface ITween<U, W> where U : struct
{
	public void Add(List<Frame<U, W>> fs);
	public void Remove(List<Frame<U, W>> fs);

	/// <summary>
	/// Returns a keyframe strictly after the input time. If t is beyond the last keyframe, return the current frame.
	/// </summary>
	/// <param name="t"></param>
	/// <returns></returns>
	public Frame<U, W>? Next(ulong t);

	public Frame<U, W>? Get(ulong t);
	public List<Frame<U, W>> Slice(ulong? lo, ulong? hi);
	public void Cut(ulong t);
	public void Merge(ulong t, List<Frame<U, W>> fs);
	public void Flush();
	public void Clear();
}

public enum InterpolationType
{
	Linear,
	Step,
	Pulse,
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
/// <param name="K">
/// Represents if this object is a keyframe (i.e. stored explicitly in the
/// tween) or an interpolated value.
/// </param>
public readonly record struct Frame<U, W> where U : struct
{
	public ulong T { get; }  // Timestamp
	public U V { get; }      // Value
	public W? D { get; }     // Data

	private readonly bool _k;
	public bool IsKeyFrame() => this._k;

	public Frame(ulong t, U v, W? d) : this(t, v, d, true)
	{
	}

	/// <summary>
	/// Namespace and test-level constructor for this object.
	/// </summary>
	/// <remarks>
	/// Calls from Godot-related namespaces <b>must</b> use the <c>public</c>
	/// constructor.
	/// </remarks>
	internal Frame(ulong t, U v, W? d, bool k)
	{
		this.T = t;
		this.V = v;
		this.D = d;
		this._k = k;
	}
}

public class Base<U, W>(InterpolationType t) : ITween<U, W>
	where U : struct
{
	/// <summary>
	/// The internal list of tween keyframes which is used to interpolate data at
	/// any given timestamp (given as milliseconds since the start of the
	/// program). This property is only mutated with explicit calls to
	/// <see cref="Tween{U, W}.Flush"> list.
	/// </summary>
	private SortedList<ulong, Frame<U, W>> _keyframes = [];

	/// <summary>
	/// The set of keyframe buffers which needs to be written to the internal
	/// <see cref="Tween{U, W}._keyframes"> list.
	/// </summary>
	private List<(ulong T, Frame<U, W>? F)> _buf = [];

	public InterpolationType InterpolationType { get; } = t;

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
		if (this._keyframes.Count == 0)
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
	/// <see cref="Base{U, W}.LowerBound">.
	/// </summary>
	internal Frame<U, W>? UpperBound(ulong t)
	{
		if (this._keyframes.Count == 0)
		{
			return null;
		}

		var lb = this.LowerBound(t);
		if (!lb.HasValue)
		{
			return this._keyframes.GetValueAtIndex(0);
		}
		else if (lb.Value.T == t)
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

	public Frame<U, W>? Next(ulong t)
	{
		Frame<U, W>? f = this.UpperBound(t);
		if (f.HasValue)
		{
			if (f.Value.T == t)
			{
				int i = this._keyframes.IndexOfKey(t) + 1;
				if (i >= this._keyframes.Count)
				{
					return null;
				}
				return this._keyframes.GetValueAtIndex(i);
			}
			return f;
		}
		return null;
	}

	private static U InterpolateLinear(U lo, U hi, float dt)
	{
		throw new ArgumentException(
			$"Unsupported Linear interpolation data type {typeof(U)}");
	}

	private static DF.Lib.Position.Position InterpolateLinear(
		DF.Lib.Position.Position lo,
		DF.Lib.Position.Position hi,
		float dt) => new(
			Base<Godot.Vector3, W>.InterpolateLinear(lo.P, hi.P, dt),
			Base<float, W>.InterpolateLinear(lo.T, hi.T, dt));

	private static Godot.Vector2 InterpolateLinear(
		Godot.Vector2 lo,
		Godot.Vector2 hi,
		float dt) => new(
			lo.X + (hi.X - lo.X) * dt,
			lo.Y + (hi.Y - lo.Y) * dt);

	private static Godot.Vector3 InterpolateLinear(
		Godot.Vector3 lo,
		Godot.Vector3 hi,
		float dt) => new(
			lo.X + (hi.X - lo.X) * dt,
			lo.Y + (hi.Y - lo.Y) * dt,
			lo.Z + (hi.Z - lo.Z) * dt);

	private static float InterpolateLinear(
		float lo,
		float hi,
		float dt) => lo + (hi - lo) * dt;

	/// <summary>
	/// Schedules adding <i>or updating</i> frames to the tween.
	/// </summary>
	public void Add(List<Frame<U, W>> fs) => fs.ForEach(f => this._buf.Add((f.T, f)));

	/// <summary>
	/// Schedules removing frames from the tween.
	/// </summary>
	public void Remove(List<Frame<U, W>> fs) => fs.ForEach(f => this._buf.Add((f.T, null)));

	/// <summary>
	/// Returns the interpolated tween frame at the given timestamp. Returns null
	/// if the timestamp is before the first defined point.
	/// </summary>
	public Frame<U, W>? Get(ulong t)
	{
		(Frame<U, W>? lb, Frame<U, W>? ub) = (
			this.LowerBound(t),
			this.UpperBound(t));

		if (lb.HasValue)
		{
			// t lies on an explicit keyframe.
			if (t == lb.Value.T)
			{
				return lb;
			}
			// t lies beyond the last known explicit keyframe -- the tween should
			// pause at the last known value.
			else if (!ub.HasValue)
			{
				return new Frame<U, W>(t, lb.Value.V, default(W), false);
			}
			else
			{
				switch (this.InterpolationType)
				{
					case InterpolationType.Pulse:
						return new Frame<U, W>(t, default(U), default(W), false);
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
							(float)(t - lb.Value.T)) / (
							(float)(ub.Value.T - lb.Value.T));
						return new Frame<U, W>(
							t,
							Base<U, W>.InterpolateLinear(
								(dynamic)lb.Value.V,
								(dynamic)ub.Value.V,
								dt),
							default(W),
							false);
					case InterpolationType.Step:
						return new Frame<U, W>(t, lb.Value.V, default(W), false);
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
	/// Returns all frames in the closed interval <c>[lo, hi]</c>. If the
	/// interval bounds <c>lo</c> and <c>hi</c> are not a keyframe, include the
	/// interpolated frame at the given bounds. If <c>lo</c> or <c>hi</c> are set
	/// to <c>null</c>, return the open interval <c>(-inf, inf)</c> instead.
	/// </remarks>
	public List<Frame<U, W>> Slice(ulong? lo, ulong? hi)
	{
		var slice = new List<Frame<U, W>>();

		if (this._keyframes.Count == 0)
		{
			return slice;
		}

		if (lo.HasValue && hi.HasValue && hi.Value < lo.Value)  // Invalid input.
		{
			return slice;
		}

		Frame<U, W>? lb = this.UpperBound(
			lo ?? this._keyframes.GetKeyAtIndex(0));
		Frame<U, W>? ub = this.LowerBound(
			hi ?? this._keyframes.GetKeyAtIndex(
				this._keyframes.Count - 1));

		// If `lo` is beyond the last known keyframe, then the upper bound of `lb`
		// does not exist, and `lb` will return null. Here, ub contains the value
		// of the last known keyframe; we know that `lo < hi` by virtue of the
		// check before, which is to say, the lower bound of `hi` is the same as
		// the lower bound of `lo`.
		if (!lb.HasValue && ub.HasValue && lo.HasValue && hi.HasValue)
		{
			if (this.InterpolationType != InterpolationType.Pulse)
			{
				slice.Add(this.Get(lo.Value)!.Value);
				slice.Add(this.Get(hi.Value)!.Value);
			}
		}

		// `ub` should always be defined by this point. `lb` may be null, as per
		// above.
		if (!lb.HasValue || !ub.HasValue)
		{
			return slice;
		}

		if (lo.HasValue && lo.Value != lb.Value.T && this.InterpolationType != InterpolationType.Pulse)
		{
			Frame<U, W>? f = this.Get(lo.Value);
			if (f.HasValue)
			{
				slice.Add(f.Value);
			}
		}

		for (
			var i = this._keyframes.IndexOfKey(lb.Value.T);
			i <= this._keyframes.IndexOfKey(ub.Value.T);
			i++)
		{
			slice.Add(this._keyframes.GetValueAtIndex(i));
		}

		if (hi.HasValue && hi.Value != ub.Value.T && this.InterpolationType != InterpolationType.Pulse)
		{
			Frame<U, W>? f = this.Get(hi.Value);
			if (f.HasValue)
			{
				slice.Add(f.Value);
			}

		}

		return slice;
	}

	/// <summary>
	/// Remove all keyframes in the half-open interval <c>[t, inf)</c>.
	/// </summary>
	public void Cut(ulong t)
	{
		Frame<U, W>? lb = this.UpperBound(t);
		var frames = new System.Collections.Generic.List<Frame<U, W>>();
		for (
			int i = lb.HasValue ? this._keyframes.IndexOfKey(lb.Value.T) : 0;
			i < this._keyframes.Count;
			i++)
		{
			frames.Add(this._keyframes.GetValueAtIndex(i));
		}
		this.Remove(frames);
	}

	/// <summary>
	/// Replace all keyframes in the open interval <c>(t, inf)</c>.
	/// </summary>
	/// <remarks>
	/// Ensures the value of the tween at <c>t</c> is preserved, including any
	/// metadata associated with a keyframe.
	/// </remarks>
	public void Merge(ulong t, List<Frame<U, W>> fs)
	{
		Frame<U, W>? f = this.Get(t);
		this.Cut(t);
		if (f.HasValue)
		{
			this.Add([
				new Frame<U, W>(
					f.Value.T,
					f.Value.V,
					f.Value.D,
					true)]);
		}

		this.Add(fs);
	}

	/// <summary>
	/// Commits all writes to <see cref="Base._buf" /> to the internal
	/// <see cref="Base._keyframes" /> list.
	/// </summary>
	public void Flush()
	{
		foreach (var (T, F) in this._buf)
		{
			if (this._keyframes.ContainsKey(T))
			{
				// If a value already exists at the target timestamp, overwrite with
				// new value.
				if (F.HasValue)
				{
					this._keyframes.SetValueAtIndex(this._keyframes.IndexOfKey(T), F.Value);
				}
				else
				{
					this._keyframes.Remove(T);
				}
			}
			else if (F.HasValue)
			{
				this._keyframes.Add(T, F.Value);
			}
		}

		this._buf.Clear();
	}

	/// <summary>
	/// Schedules all keyframes in the tween for deletion.
	/// </summary>
	public void Clear() => this.Remove(this._keyframes.Values.ToList());
}
