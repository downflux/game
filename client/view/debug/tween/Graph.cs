namespace DF.View.Debug.Tween;

public partial class Graph<U, W> : Base<U, W> where U : struct
{
  public string Label = "";
  private int _font_size = 12;


  /// <summary>
  /// Size of the time window (x-axis) in ms.
  /// </summary>
  public ulong WindowSize = 10000;

  public override void _Draw()
  {
    base._Draw();

    this.DrawLine(
      new Godot.Vector2I(0, this.Dimension.Y),
      this.Dimension,
      this.Tween == null ? Godot.Colors.Red : Godot.Colors.Green,
      1);

    this.DrawLine(
      Godot.Vector2.Zero,
      new Godot.Vector2(0, this.Dimension.Y),
      this.Tween == null ? Godot.Colors.Red : Godot.Colors.Green,
      1);

    this.DrawString(
        Godot.ThemeDB.FallbackFont,
        new Godot.Vector2(3, _font_size + 3),
        this.Tween == null ? $"{this.Label} (unlinked)" : this.Label,
        modulate: this.Tween == null ? Godot.Colors.Red : Godot.Colors.White,
        fontSize: _font_size);
  }
}