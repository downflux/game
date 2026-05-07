using Godot;
using System;
using System.Collections.Generic;

namespace DF.Instances.Tween;

public partial class Velocity(List<DF.Lib.Tween.Frame<DF.Lib.Position.Velocity, bool>> fs) : Base<DF.Lib.Position.Velocity, bool>(
  new DF.Lib.Tween.Base<DF.Lib.Position.Velocity, bool>(
    DF.Lib.Tween.InterpolationType.Step), fs)
{
  public Velocity() : this([])
  {
  }
}