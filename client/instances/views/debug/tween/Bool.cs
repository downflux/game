using System.Collections.Generic;
using System.Threading;
using DF.Instances.Timer;

namespace DF.Instances.Debug.Tween;

internal class ToFloat(
  DF.Instances.Tween.ITweenRO<bool, bool> tween) : DF.Instances.Tween.ITweenRO<float, bool>
{
  private DF.Instances.Tween.ITweenRO<bool, bool> _tween = tween;

  public DF.Lib.Tween.Frame<float, bool>? Get(ulong t)
  {
    DF.Lib.Tween.Frame<bool, bool>? f = this._tween.Get(t);
    if (f.HasValue)
    {
      return new(f.Value.T, f.Value.V ? 1 : 0, f.Value.D, f.Value.IsKeyFrame());
    }
    return null;
  }

  public List<DF.Lib.Tween.Frame<float, bool>> Slice(ulong? hi, ulong? lo)
  {
    List<DF.Lib.Tween.Frame<float, bool>> fs = [];
    foreach (var f in this._tween.Slice(hi, lo))
    {
      fs.Add(new(f.T, f.V ? 1 : 0, f.D, f.IsKeyFrame()));
    }
    return fs;
  }

  public DF.Lib.Tween.InterpolationType Type() => this._tween.Type();
}