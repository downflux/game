using System.Collections.Generic;
using System.Linq;

namespace DF.Lib.Tween.Float;

public partial class Linear<W> : Base<W>
{
  public Dictionary<float, EdgeType> WatchPoints = [];

  public event ValueTriggerEventHandler<W>? ValueTriggerEvent;

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
        this.ValueTriggerEvent?.Invoke(this, new ValueTriggerEventHandlerArgs<W>(f, v, et));
      }
    }
  }
}

public delegate void ValueTriggerEventHandler<W>(
  object sender,
  ValueTriggerEventHandlerArgs<W> e);

public class ValueTriggerEventHandlerArgs<W>(
  DF.Lib.Tween.Frame<float, W> f, float v, EdgeType et) : DF.Lib.Tween.KeyframeTriggerEventHandlerArgs<float, W>(f)
{
  public float V { get; } = v;
  public EdgeType EdgeType { get; } = et;
}