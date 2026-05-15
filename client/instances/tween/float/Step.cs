using System;
using System.Collections.Generic;

namespace DF.Instances.Tween.Float;

public partial class Step<W> : Base<float, W>
{
  public Step() : base(new DF.Lib.Tween.Float<W>(DF.Lib.Tween.InterpolationType.Step))
  {
  }
}
