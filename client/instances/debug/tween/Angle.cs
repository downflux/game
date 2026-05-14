using System.Collections.Generic;

namespace DF.Instances.Debug.Tween;

/// <summary>
/// Transform a <see cref="DF.Lib.Position.Position"/> tween and extract just
/// the angular component. 
/// </summary>
internal class ToAngle(DF.Instances.Tween.ITweenRO<DF.Lib.Position.Position, DF.Lib.Path.KeyFrameType> tween) : DF.Instances.Tween.ITweenRO<float, DF.Lib.Path.KeyFrameType>
{
  private DF.Instances.Tween.ITweenRO<DF.Lib.Position.Position, DF.Lib.Path.KeyFrameType> _tween = tween;

  public DF.Lib.Tween.Frame<float, DF.Lib.Path.KeyFrameType>? Get(ulong t)
  {
    DF.Lib.Tween.Frame<DF.Lib.Position.Position, DF.Lib.Path.KeyFrameType>? f = this._tween.Get(t);
    if (f.HasValue)
    {
      return new(f.Value.T, f.Value.V.T, f.Value.D, f.Value.IsKeyFrame());
    }
    return null;
  }

  public List<DF.Lib.Tween.Frame<float, DF.Lib.Path.KeyFrameType>> Slice(ulong? hi, ulong? lo)
  {
    List<DF.Lib.Tween.Frame<float, DF.Lib.Path.KeyFrameType>> fs = [];
    foreach (var f in this._tween.Slice(hi, lo))
    {
      fs.Add(new(f.T, f.V.T, f.D, f.IsKeyFrame()));
    }
    return fs;
  }
}

public partial class Angle : DF.Instances.Debug.Tween.Float<DF.Lib.Path.KeyFrameType>
{
  public Angle() : base()
  {
    this.Label = "Angle";
  }

  public override void _Draw()
  {
    base._Draw();
  }
}