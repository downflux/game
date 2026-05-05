using System;
using System.Collections.Generic;

namespace DF.Instances.Tween.Float;

public partial class Linear<W>(List<DF.Lib.Tween.Frame<float, W>> fs) : Base<float, W>(
	new DF.Lib.Tween.Float<W>(
			DF.Lib.Tween.InterpolationType.Linear), fs)
{
	[Godot.Export]
	required public Godot.Collections.Dictionary<float, DF.Lib.Tween.EdgeType> WatchPoints;

	public event TriggerEventHandler<float, W>? ValueTriggerEvent;

	public Linear() : this([])
	{
	}

	public override void _Process(double dt)
	{
		base._Process(dt);

		foreach (var (v, et) in this.WatchPoints)
		{
			List<DF.Lib.Tween.Frame<float, W>> fs = (
				(DF.Lib.Tween.Float<W>)(this._tween)).Find(
					this._timer().PrevTick(), this._timer().CurrTick(), v, et);
			foreach (var f in fs)
			{
				this.ValueTriggerEvent?.Invoke(this, new TriggerEventHandlerArgs<float, W>(f));
			}
		}
	}
}
