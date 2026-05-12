using System;
using System.Collections.Generic;
using System.Reflection.Emit;
using DF.Instances.Timer;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using Microsoft.CodeAnalysis.Diagnostics;

namespace DF.Instances.Debug.Tween;

internal class Shim(DF.Instances.Tween.ITweenRO<DF.Lib.Position.Position, DF.Lib.Path.KeyFrameType> tween) : DF.Instances.Tween.ITweenRO<float, DF.Lib.Path.KeyFrameType>
{
  private DF.Instances.Tween.ITweenRO<DF.Lib.Position.Position, DF.Lib.Path.KeyFrameType> _tween = tween;

  public DF.Lib.Tween.Frame<float, DF.Lib.Path.KeyFrameType>? Get(ulong t)
  {
    DF.Lib.Tween.Frame<DF.Lib.Position.Position, DF.Lib.Path.KeyFrameType>? f = this._tween.Get(t);
    if (f.HasValue)
    {
      return new(f.Value.T, f.Value.V.T, f.Value.D);
    }
    return null;
  }

  public List<DF.Lib.Tween.Frame<float, DF.Lib.Path.KeyFrameType>> Slice(ulong? hi, ulong? lo)
  {
    List<DF.Lib.Tween.Frame<float, DF.Lib.Path.KeyFrameType>> fs = [];
    foreach (var f in this._tween.Slice(hi, lo))
    {
      fs.Add(new(f.T, f.V.T, f.D));
    }
    return fs;
  }
}

public partial class Angle : DF.Instances.Debug.Tween.Float<DF.Lib.Path.KeyFrameType>
{
  public Angle()
  {
    this.Label = "Angle";
  }
}