using System;
using System.Collections.Generic;

namespace DF.Lib.Tween;

/// <summary>
/// Edge detection type. Used to trigger signals when a tween falls below or rises
/// above a specific value.
/// </summary>
public enum EdgeType
{
	/// <summary>
	/// Trigger a signal when a tween falls below a value <c>v</c>. 
	/// </summary>
	FallingEdge,

	/// <summary>
	/// Trigger a signal when a tween rises above a value <c>v</c>. 
	/// </summary>
	RisingEdge,
}

public class Float<W>(InterpolationType t) : Base<float, W>(t)
{
	/// <summary>
	/// Find the linear intercept point in the half-open interval <c>(lb, ub]</c>.
	/// </summary>
	/// <remarks>
	/// This function assumes a smooth linear function in between the two
	/// endpoints. Therefore, if there is a <c>null</c> value as an endpoint,
	/// there is no data to interpolate, and therefore, this function will return
	/// a null result.
	/// </remarks>
	internal Frame<float, W>? Intercept(Frame<float, W>? lb, Frame<float, W>? ub, float v, EdgeType et)
	{
		if (this.InterpolationType != InterpolationType.Linear)
		{
			return null;
		}

		if (lb.HasValue && ub.HasValue && lb.Value.T > ub.Value.T)
		{
			return null;
		}

		if (!lb.HasValue || !ub.HasValue)
		{
			return null;
		}

		if (lb.Value.T > ub.Value.T)
		{
			return null;
		}

		// (ub.V - lb.V) / (ub.T - lb.T) = (ub.V - v) / (ub.T - t)
		//   => t = ub.T - dt / dv (ub.V - v)
		float dt = ub.Value.T - lb.Value.T;
		float dv = ub.Value.V - lb.Value.V;

		if (dt == 0 && v != ub.Value.V)
		{
			return null;
		}

		float t = ub.Value.T - (ub.Value.V - v) * dt / dv;
		if (t <= (float)lb.Value.T || t > (float)ub.Value.T)
		{
			return null;
		}

		if (
			(
				lb.Value.V < ub.Value.V && et == EdgeType.RisingEdge) || (
				lb.Value.V > ub.Value.V && et == EdgeType.FallingEdge))
		{
			ulong u = (ulong)Math.Ceiling(t);
			if (u > lb.Value.T)
			{
				return this.Get(u);
			}
		}

		return null;
	}

	/// <summary>
	/// Get all intersecting frames for the tween in the closed interval
	/// <c>[lo, hi]</c> given the value <c>v</c>.
	/// </summary>
	/// <param name="et">
	/// <see cref="EdgeType" /> of <c>v</c>, e.g. if <c>EdgeType</c> is
	/// <c>FallingEdge</c>, return only if <c>lo.V &gt; v &gt; hi.V</c>.
	/// </param>
	public List<Frame<float, W>> Find(ulong? lo, ulong? hi, float v, EdgeType et)
	{
		List<Frame<float, W>> slice = this.Slice(lo, hi);

		var results = new List<Frame<float, W>>();

		for (var i = 0; i < slice.Count; i++)
		{
			Frame<float, W>? f = this.Intercept(
				i == 0 ? null : slice[i - 1],
				slice[i],
				v,
				et);
			if (f.HasValue)
			{
				results.Add(f.Value);
			}
		}

		return results;
	}
}
