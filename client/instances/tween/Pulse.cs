using System.Collections.Generic;

namespace DF.Instances.Tween;

public partial class Pulse(List<DF.Lib.Tween.Frame<bool, bool>> fs) : DF.Instances.Tween.Bool.Pulse<bool>(fs)
{
  public Pulse() : this([])
  {
  }
}