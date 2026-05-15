using Godot;

namespace DF.Instances.Debug.Tween;

public partial class Base<U, W> : Node2D where U : struct
{
  // TODO(minkezhang): Rename Node.
  public DF.Instances.Tween.ITweenRO<U, W>? Tween = null;

  internal DF.Lib.Timer.D _timer = () => DF.Instances.Timer.T.S();

  // TODO(minkezhang): Remove Export.
  [Godot.Export]
  public Vector2I Dimension;

  public override void _Process(double delta)
  {
    base._Process(delta);

    this.QueueRedraw();
  }
}