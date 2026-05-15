using Godot;
using System;
using System.Collections.Generic;

namespace DF.Instances.Tween;

public partial class Velocity : Base<DF.Lib.Position.Velocity, bool>
{
  public Velocity() : base(new DF.Lib.Tween.Base<DF.Lib.Position.Velocity, bool>(DF.Lib.Tween.InterpolationType.Step))
  {
  }
}