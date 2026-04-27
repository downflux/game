using Godot;
using System;
using System.Collections.Generic;
using System.ComponentModel;

namespace DF.Instances.Tween;

public partial class Vector3(List<DF.Lib.Tween.Frame<Godot.Vector3, bool>> fs) : Base<Godot.Vector3, bool>(
  new DF.Lib.Tween.Base<Godot.Vector3, bool>(
      DF.Lib.Tween.InterpolationType.Linear), fs)
{
  public Vector3() : this([])
  {
  }
}