using System.Collections.Generic;

namespace DF.Instances.Tween;

public partial class Position(List<DF.Lib.Tween.Frame<Godot.Vector3, DF.Lib.Path.KeyFrameType>> fs) : DF.Instances.Tween.Vector3<DF.Lib.Path.KeyFrameType>(fs)
{
  public Position() : this([])
  {
  }
}