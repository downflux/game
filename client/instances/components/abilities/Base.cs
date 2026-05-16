using System;
using System.Collections.Generic;

namespace DF.Instances.Components.Abilities;

public partial class Base : Godot.Node
{
  internal DF.Lib.Timer.D _timer = () => DF.Instances.Timer.T.S();

  public virtual bool Trigger() => false;
}