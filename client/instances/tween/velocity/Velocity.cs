using Godot;
using System;
using System.Collections.Generic;

namespace DF.Instances.Tween;

public partial class Velocity(List<DF.Lib.Tween.Frame<float, bool>> fs) : DF.Instances.Tween.Float.Step<bool>(fs)
{
  public Velocity() : this([])
  {
  }
}
