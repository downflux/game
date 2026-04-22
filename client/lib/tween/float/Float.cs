using System;

namespace DF.Lib.Tween;

public enum EdgeType
{
	FallingEdge,
	RisingEdge,
}

public class Float<W> : Base<float, W>
{
	public Float(InterpolationType t) : base(t)
	{
	}
	
	internal Frame<float, W>? Intercept(Frame<float, W>? lb, Frame<float, W>? ub, float v, EdgeType et)
	{
		if (lb.HasValue && ub.HasValue && lb.Value.T > ub.Value.T)
		{
			return null;
		}
		
		if (!lb.HasValue || !ub.HasValue)
		{
			if (!lb.HasValue && ub.HasValue)
			{
				return v == ub.Value.T ? ub : null;
			}
			if (!ub.HasValue && lb.HasValue)
			{
				return v == lb.Value.T ? lb : null;
			}
			return null;
		}
		
		if (lb.Value.T > ub.Value.T)
		{
			return null;
		}
		
		switch (this.InterpolationType)
		{
			case InterpolationType.Linear:
				// (v - lb.V) = m * (t - lb.T), where m = dt / dv
				//   => t = (v - lb.V) * dv / dt + lb.T
				float dt = ub.Value.T - lb.Value.T;
				float dv = ub.Value.V - lb.Value.V;
				
				if (dt == 0 && v != ub.Value.V)
				{
					return null;
				}
				
				float t = (v - lb.Value.V) * dv / dt + lb.Value.T;
				if (t < (float)lb.Value.T || t > (float)ub.Value.T)
				{
					return null;
				}
				
				if (
					(
						lb.Value.V < ub.Value.V && et == EdgeType.RisingEdge) || (
						lb.Value.V > ub.Value.V && et == EdgeType.FallingEdge))
				{
					return this.Get((ulong)Math.Round(t));
				}
				
				return null;
			case InterpolationType.Step:
				if (v == lb.Value.T)
				{
					return lb;
				}
				if (v == ub.Value.T)
				{
					return ub;
				}
				
				return null;
		}
		return null;
	}
	
	/// <summary>
	/// Get all intersecting frames for the tween in the closed interval
	/// <c>[lo, hi]</c> given the value <c>v</c>.
	/// </summary>
	/// <param name="et">
	/// <see cref="DF.Lib.Tween.EdgeType" /> of <c>v</c>. If <c>EdgeType</c> is
	/// <c>FallingEdge</c>, return only if <c>lo.V &gt; v &gt; hi.V</c>.
	/// </param>
	/// <remarks>
	/// We are assuming lb and ub are adjacent frames with no intermediate
	/// keyframes in between.
	/// </remarks>
	public System.Collections.Generic.List<Frame<float, W>> Find(ulong? lo, ulong? hi, float v, EdgeType et)
	{
		System.Collections.Generic.List<Frame<float, W>> slice = this.Slice(lo, hi);
		
		var results = new System.Collections.Generic.List<Frame<float, W>>();
		
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
