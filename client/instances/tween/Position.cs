using System.Collections.Generic;

namespace DF.Instances.Tween;

public partial class Position : Base<DF.Lib.Position.Position, DF.Lib.Path.KeyFrameType>
{
  public Position() : base(new DF.Lib.Tween.Base<DF.Lib.Position.Position, DF.Lib.Path.KeyFrameType>(DF.Lib.Tween.InterpolationType.Linear))
  {
  }
}