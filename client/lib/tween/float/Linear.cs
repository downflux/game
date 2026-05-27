using System.Collections.Generic;

namespace DF.Lib.Tween.Float;

public partial class Linear<W> : Float<W>
{
  public Dictionary<float, EdgeType> WatchPoints = [];

  public event ValueTriggerEventHandler<W>? ValueTriggerEvent;

  public Linear() : base(InterpolationType.Linear)
  {
  }

  public override void Process(ulong lb, ulong ub)
  {
    base.Process(lb, ub);

    foreach (var (v, et) in this.WatchPoints)
    {
      List<DF.Lib.Tween.Frame<float, W>> fs = this.Find(lb, ub, v, et);
      foreach (var f in fs)
      {
        this.ValueTriggerEvent?.Invoke(this, new ValueTriggerEventHandlerArgs<W>(f, v, et));
      }
    }
  }
}
