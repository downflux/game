using Godot;

namespace DF.Instances.Debug.Tween;

public partial class Base<U, W> : Node2D where U : struct
{
  public DF.Instances.Tween.ITweenRO<U, W>? Tween = null;
  public string Label = "";
  private const int _font_size = 12;

  /// <summary>
  /// Size of the window in ms.
  /// </summary>
  public ulong WindowSize = 10000;

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
      this.Tween == null ? Godot.Colors.Red : Godot.Colors.Green,
      1);

    this.DrawLine(
      this.Position,
      this.Position + new Godot.Vector2(0, this.Dimension.Y),
      this.Tween == null ? Godot.Colors.Red : Godot.Colors.Green,
      1);

    this.DrawString(
        Godot.ThemeDB.FallbackFont,
        this.Position + new Godot.Vector2(0, this.Dimension.Y) + new Godot.Vector2(0, _font_size),
        this.Tween == null ? $"{this.Label} (unlinked)" : this.Label,
        modulate: this.Tween == null ? Godot.Colors.Red : Godot.Colors.White,
        fontSize: _font_size);
  }

  public override void _Process(double delta)
  {
    base._Process(delta);

    this.QueueRedraw();
  }
}