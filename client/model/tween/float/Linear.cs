using System.Collections.Generic;

namespace DF.Model.Tween.Float;

public delegate void ValueTriggerEventHandler<W>(
	object sender,
	ValueTriggerEventHandlerArgs<W> e);

public class ValueTriggerEventHandlerArgs<W>(
	DF.Lib.Tween.Frame<float, W> f, float v, DF.Lib.Tween.EdgeType et) : DF.Model.Tween.KeyframeTriggerEventHandlerArgs<float, W>(f)
{
	public float V { get; } = v;
	public DF.Lib.Tween.EdgeType EdgeType { get; } = et;
}

public partial class Linear<W> : Base<float, W>
{
	public Godot.Collections.Dictionary<float, DF.Lib.Tween.EdgeType> WatchPoints = [];

	public event ValueTriggerEventHandler<W>? ValueTriggerEvent;

	public Linear() : base(new DF.Lib.Tween.Float<W>(DF.Lib.Tween.InterpolationType.Linear))
	{
	}

	public override void _Process(double dt)
	{
		base._Process(dt);

		foreach (var (v, et) in this.WatchPoints)
		{
			List<DF.Lib.Tween.Frame<float, W>> fs = (
				(DF.Lib.Tween.Float<W>)this._tween).Find(
					this._timer().PrevTick(), this._timer().CurrTick(), v, et);
			foreach (var f in fs)
			{
				this.ValueTriggerEvent?.Invoke(this, new ValueTriggerEventHandlerArgs<W>(f, v, et));
			}
		}
	}
}
