using System;
using System.Collections.Generic;

namespace DF.Instances.Tween;



public partial class Float<W> : Base<float, W>
{
	[Godot.Export]
	required public Godot.Collections.Dictionary<float, DF.Lib.Tween.EdgeType> WatchPoints;

	public event TriggerEventHandler<float, W>? ValueTriggerEvent;

	private ulong _last_tick_ms = 0;

	public Float() : base(
		new DF.Lib.Tween.Float<W>(
			DF.Lib.Tween.InterpolationType.Linear))
	{
	}

	public override void _Process(double dt)
	{
		base._Process(dt);

		var tick_ms = Godot.Time.GetTicksMsec();

		foreach (var (v, et) in this.WatchPoints)
		{
			List<DF.Lib.Tween.Frame<float, W>> fs = (
				(DF.Lib.Tween.Float<W>)(this._tween)).Find(
					this._last_tick_ms, tick_ms, v, et);
			foreach (var f in fs)
			{
				this.ValueTriggerEvent?.Invoke(this, new TriggerEventHandlerArgs<float, W>(f));
			}
		}
		this._last_tick_ms = tick_ms;
	}
}
