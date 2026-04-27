using Godot;
using System;
using System.ComponentModel;

namespace DF.Instances.Tween;

public partial class Vector3 : Base<Godot.Vector3, bool>
{
  public Vector3() : base(
    new DF.Lib.Tween.Base<Godot.Vector3, bool>(
      DF.Lib.Tween.InterpolationType.Linear))
  {
  }
}