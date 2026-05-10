using Godot;

namespace DF.Instances.Debug.Tween;

public partial class Base<U, W> : Node2D where U : struct
{
  public DF.Instances.Tween.Base<U, W> Tween;

  internal DF.Lib.Timer.D _timer = () => DF.Instances.Timer.T.S();

  [Godot.Export]
  public Vector2I Dimension;

  public int Height;

  public override void _Draw()
  {
    base._Draw();

    this.DrawLine(
      this.Position + new Godot.Vector2I(0, this.Dimension.Y),
      this.Position + this.Dimension,
      Godot.Colors.Green,
      1);

    this.DrawLine(
      this.Position,
      this.Position + new Godot.Vector2(0, this.Dimension.Y),
      Godot.Colors.Green,
      1);
  }

  public override void _Process(double delta)
  {
    base._Process(delta);

    this.QueueRedraw();
  }
}