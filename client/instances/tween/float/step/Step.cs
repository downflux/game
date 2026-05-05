using System;
using System.Collections.Generic;

namespace DF.Instances.Tween.Float;

public partial class Step<W>(List<DF.Lib.Tween.Frame<float, W>> fs) : Base<float, W>(
  new DF.Lib.Tween.Float<W>(
      DF.Lib.Tween.InterpolationType.Step), fs)
{
  public Step() : this([])
  {
  }
}
