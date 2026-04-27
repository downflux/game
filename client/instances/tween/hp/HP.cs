using Godot;
using System;
using System.Collections.Generic;

namespace DF.Instances.Tween;

public partial class HP(List<DF.Lib.Tween.Frame<float, bool>> fs) : DF.Instances.Tween.Float<bool>(fs)
{
  public HP() : this([])
  {
  }
}
