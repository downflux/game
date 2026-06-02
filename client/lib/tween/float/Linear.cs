using System.Collections.Generic;
using System.Linq;
using System;

namespace DF.Lib.Tween.Float;

public partial class Linear<W> : Base<W>
{
  public Dictionary<float, EdgeType> WatchPoints = [];

  private readonly DF.Lib.Event.WeakEventHandler<ValueTriggerEventHandlerArgs<W>> _value_trigger_event = new();
  public event EventHandler<ValueTriggerEventHandlerArgs<W>> ValueTriggerEvent
  {
    add
    {

      _value_trigger_event.Add(value);
    }
    remove
    {
      _value_trigger_event.Remove(value);
    }
  }

  public Linear() : base(InterpolationType.Linear)
  {
  }

  public override void Raise(ulong lb, ulong ub)
  {
    base.Raise(lb, ub);

    foreach (var (v, et) in this.WatchPoints)
    {
      foreach (var f in this.Find(lb, ub, v, et).Where(f => f.T < ub))
      {
        this._value_trigger_event.Invoke(this, new ValueTriggerEventHandlerArgs<W>(f, v, et));
      }
    }
  }
}

public class ValueTriggerEventHandlerArgs<W>(
  DF.Lib.Tween.Frame<float, W> f, float v, EdgeType et) : DF.Lib.Tween.KeyframeTriggerEventHandlerArgs<float, W>(f)
{
  public float V { get; } = v;
  public EdgeType EdgeType { get; } = et;
}