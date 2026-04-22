using System;
using System.Collections.Generic;

namespace DF.Lib.Float;

public partial class FloatNode : DF.Lib.TweenNode.TweenNode<float>
{
	[Godot.Export]
	required public Godot.Collections.Dictionary<float, DF.Lib.Tween.EdgeType> WatchPoints;
	
	public event DF.Lib.TweenNode.FrameTriggerEventHandler<float>? ValueTriggerEvent;
	
	private ulong _last_tick_ms = 0;
	
	public FloatNode() : base()
	{
		this._tween = new DF.Lib.Tween.Float<DF.Lib.TweenNode.FrameTriggerEventHandler<float>>(
			this.InterpolationType);
	}
	
	public override void _Process(double dt)
	{
		base._Process(dt);
		
		var tick_ms = Godot.Time.GetTicksMsec();
		
		foreach (var (v, et) in this.WatchPoints)
		{
			List<DF.Lib.Tween.Frame<float, DF.Lib.TweenNode.FrameTriggerEventHandler<float>>> fs = ((DF.Lib.Tween.Float<DF.Lib.TweenNode.FrameTriggerEventHandler<float>>)(this._tween)).Find(
				this._last_tick_ms, tick_ms, v, et);
			
			foreach (var f in fs)
			{
				this.ValueTriggerEvent?.Invoke(this, new DF.Lib.TweenNode.FrameTriggerEventArgs<float>(f));
			}
		}
		this._last_tick_ms = tick_ms;
	}
}
