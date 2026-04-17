using System;
using System.Collections.Generic;

namespace DF.Lib.Float;

public enum ValueTriggerMode
{
	FallingEdge,
	RisingEdge,
}

public partial class Node : DF.Lib.TweenNode.TweenNode<float>
{
	[Godot.Export]
	required public Godot.Collections.Dictionary<float, ValueTriggerMode> WatchPoints;
	
	public event DF.Lib.TweenNode.FrameTriggerEventHandler<float>? ValueTriggerEvent;
	
	/// <summary>
	/// </summary>
	/// <remarks>
	/// We are assuming lb and ub are adjacent frames with no intermediate
	/// keyframes in between.
	/// </remarks>
	internal DF.Lib.Tween.Frame<float, DF.Lib.TweenNode.FrameTriggerEventHandler<float>>? Find(
		DF.Lib.Tween.Frame<float, DF.Lib.TweenNode.FrameTriggerEventHandler<float>> lb,
		DF.Lib.Tween.Frame<float, DF.Lib.TweenNode.FrameTriggerEventHandler<float>> ub,
		float v)
	{
		// This covers the Step case as well.
		if (v == lb.V)
		{
			return lb;
		}
		if (v == ub.V)
		{
			return ub;
		}
		
		switch (this.InterpolationType)
		{
			case DF.Lib.Tween.InterpolationType.Linear:
				// (v - lb.V) = m * (t - lb.T), where m = dt / dv
				// => t = (v - lb.V) * dv / dt + lb.T
				float dt = ub.T - lb.T;
				float dv = ub.V - lb.V;
				
				if (dt == 0 && v != ub.V)
				{
					return null;
				}
				
				float t = (v - lb.V) * dv / dt + lb.T;
				if (t < (float)lb.T || t > (float)ub.T)
				{
					return null;
				}
				
				return this._tween.Get((ulong)Math.Round(t));
		}
		return null;
	}
	
	private ulong _last_tick_ms = 0;
	
	public override void _Process(double dt)
	{
		base._Process(dt);
		
		var tick_ms = Godot.Time.GetTicksMsec();
		
		var slice = this._tween.Slice(this._last_tick_ms, tick_ms);
		
		foreach (var (t, mode) in this.WatchPoints)
		{
			if (slice.Count > 1)
			{
				var f = slice[0];
				var triggered = false;
				
				switch (mode)
				{
					case ValueTriggerMode.FallingEdge:
						if (f.V <= t)
						{
							triggered = true;
						}
						break;
					case ValueTriggerMode.RisingEdge:
						if (f.V >= t)
						{
							triggered = true;
						}
						break;
					default:
						break;
				}
				if (triggered)
				{
					this.ValueTriggerEvent?.Invoke(this, new DF.Lib.TweenNode.FrameTriggerEventArgs<float>(f));  // TODO(minkezhang): Figure out a sensible value here.
				}
			}
			
			for (var i = 1; i < slice.Count; i++)
			{
				var f = slice[i - 1];
				var g = slice[i];
				var triggered = false;
				
				switch (mode)
				{
					case ValueTriggerMode.FallingEdge:
						if (f.V > t && g.V <= t)
						{
							triggered = true;
						}
						break;
					case ValueTriggerMode.RisingEdge:
						if (f.V < t && g.V >= t)
						{
							triggered = true;
						}
						break;
					default:
						break;
				}
				
				// Value has been breached.
				if (triggered)
				{
					DF.Lib.Tween.Frame<float, DF.Lib.TweenNode.FrameTriggerEventHandler<float>>? h = this.Find(f, g, t);
					if (h.HasValue)
					{
						this.ValueTriggerEvent?.Invoke(
							this, new DF.Lib.TweenNode.FrameTriggerEventArgs<float>(h.Value));
					}
				}
			}
		}
		
		this._last_tick_ms = tick_ms;
	}
}
