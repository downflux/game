using System.Collections.Generic;

namespace DF.Instances.Tween;

public partial class Position(List<DF.Lib.Tween.Frame<DF.Lib.Position.Position, DF.Lib.Path.KeyFrameType>> fs) : Base<DF.Lib.Position.Position, DF.Lib.Path.KeyFrameType>(
  new DF.Lib.Tween.Base<DF.Lib.Position.Position, DF.Lib.Path.KeyFrameType>(
    DF.Lib.Tween.InterpolationType.Linear), fs)
{
  public Position() : this([])
  {
  }
}