using System;
using System.Collections.Generic;

namespace DF.Instances.Tween.Bool;

public partial class Pulse<W> : Base<bool, W>
{
  public Pulse() : base(new DF.Lib.Tween.Bool<W>(DF.Lib.Tween.InterpolationType.Pulse))
  {
  }
}
