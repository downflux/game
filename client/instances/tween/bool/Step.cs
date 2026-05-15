using System;
using System.Collections.Generic;

namespace DF.Instances.Tween.Bool;

public partial class Step<W> : Base<bool, W>
{
  public Step() : base(new DF.Lib.Tween.Bool<W>(DF.Lib.Tween.InterpolationType.Step))
  {
  }
}
