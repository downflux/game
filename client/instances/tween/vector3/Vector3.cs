using Godot;
using System;
using System.Collections.Generic;
using System.ComponentModel;

namespace DF.Instances.Tween;

public partial class Vector3<W>(List<DF.Lib.Tween.Frame<Godot.Vector3, W>> fs) : Base<Godot.Vector3, W>(
  new DF.Lib.Tween.Base<Godot.Vector3, W>(
      DF.Lib.Tween.InterpolationType.Linear), fs)
{
  public Vector3() : this([])
  {
  }
}