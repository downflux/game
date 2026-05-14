using System;
using System.Collections.Generic;

namespace DF.Instances.Tween.Bool;

public partial class Step<W>(List<DF.Lib.Tween.Frame<bool, W>> fs) : Base<bool, W>(
  new DF.Lib.Tween.Bool<W>(
      DF.Lib.Tween.InterpolationType.Step), fs)
{
  public Step() : this([])
  {
  }
}
