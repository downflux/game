using System;
using System.Collections.Generic;

namespace DF.Instances.Tween.Bool;

public partial class Pulse<W>(List<DF.Lib.Tween.Frame<bool, W>> fs) : Base<bool, W>(
  new DF.Lib.Tween.Bool<W>(
      DF.Lib.Tween.InterpolationType.Pulse), fs)
{
  public Pulse() : this([])
  {
  }
}
