using Godot;

namespace DF.View.Debug.Tween;

public partial class Base<U, W> : Node2D where U : struct
{
  // TODO(minkezhang): Rename Node.
  public DF.Lib.Tween.ITweenRO<U, W>? Tween = null;

  internal DF.Lib.Timer.D _timer = () => DF.Model.Timer.Server.S();

  // TODO(minkezhang): Remove Export.
  [Godot.Export]
  public Vector2I Dimension;

  public override void _Process(double delta)
  {
    base._Process(delta);

    this.QueueRedraw();
  }
}