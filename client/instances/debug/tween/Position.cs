using System;
using System.Collections.Generic;
using System.Reflection.Emit;

namespace DF.Instances.Debug.Tween;

public partial class Position : DF.Instances.Debug.Tween.Base<DF.Lib.Position.Position, DF.Lib.Path.KeyFrameType>
{
  public float? YMin;
  public float? YMax;

  public Position()
  {
    this.Label = "Position";
  }

  internal (float YMin, float YMax) YRange(List<DF.Lib.Tween.Frame<DF.Lib.Position.Position, DF.Lib.Path.KeyFrameType>> fs)
  {
    if (this.YMax.HasValue)
    {
      return (this.YMin.HasValue ? this.YMin.Value : 0, this.YMax.Value);
    }

    (float ymin, float ymax) = (float.PositiveInfinity, float.NegativeInfinity);
    foreach (DF.Lib.Tween.Frame<DF.Lib.Position.Position, DF.Lib.Path.KeyFrameType> f in fs)
    {
      (ymin, ymax) = (Math.Min(ymin, f.V.T), Math.Max(ymax, f.V.T));

    }
    return (ymin, ymax);
  }

  internal static int Offset(float min, float max, float width, float v)
  {
    return (int)Math.Round((float)(v - min) / (max - min) * width);
  }

  public override void _Draw()
  {
    base._Draw();

    if (this.Tween == null)
    {
      return;
    }

    (float xmin, float xmax) = (
      ((float)this._timer().CurrTick() - (float)this.WindowSize / 2) < 0 ? 0 : (float)this._timer().CurrTick() - (float)this.WindowSize / 2,
      (float)this._timer().CurrTick() + (float)this.WindowSize / 2);

    List<DF.Lib.Tween.Frame<DF.Lib.Position.Position, DF.Lib.Path.KeyFrameType>> fs = this.Tween.Slice((ulong)xmin, (ulong)xmax);

    (float ymin, float ymax) = this.YRange(fs);

    if (fs.Count > 0)
    {
      DF.Lib.Tween.Frame<DF.Lib.Position.Position, DF.Lib.Path.KeyFrameType> f = fs[0];
      for (var i = 1; i < fs.Count; i++)
      {
        DF.Lib.Tween.Frame<DF.Lib.Position.Position, DF.Lib.Path.KeyFrameType> g = fs[i];

        Godot.Vector2I offset_f = new(
          DF.Instances.Debug.Tween.Position.Offset(xmin, xmax, this.Dimension.X, f.T),
          -DF.Instances.Debug.Tween.Position.Offset(ymin, ymax, this.Dimension.Y, f.V.T));
        Godot.Vector2I offset_g = new(
          DF.Instances.Debug.Tween.Position.Offset(xmin, xmax, this.Dimension.X, g.T),
          -DF.Instances.Debug.Tween.Position.Offset(ymin, ymax, this.Dimension.Y, g.V.T));
        Godot.Vector2 p = this.Position + new Godot.Vector2I(0, this.Dimension.Y) + offset_f;
        Godot.Vector2 q = this.Position + new Godot.Vector2I(0, this.Dimension.Y) + offset_g;

        this.DrawLine(p, q, Godot.Colors.Green, 1);
        this.DrawCircle(p, 2, f.IsKeyFrame() ? Godot.Colors.Red : Godot.Colors.Gray);
        if (i == fs.Count - 1)  // Draw last point.
        {
          this.DrawCircle(q, 2, g.IsKeyFrame() ? Godot.Colors.Red : Godot.Colors.Gray);
        }

        f = g;
      }
    }

    int curr_tick = DF.Instances.Debug.Tween.Position.Offset(xmin, xmax, this.Dimension.X, this._timer().CurrTick());

    this.DrawLine(
      this.Position + new Godot.Vector2I(curr_tick, 0),
      this.Position + new Godot.Vector2I(curr_tick, this.Dimension.Y),
      Godot.Colors.Gray,
      1);
  }

  internal void _DrawPoint(DF.Lib.Tween.Frame<float, bool> f, Godot.Vector2 p)
  {
    this.DrawCircle(p, 2, f.IsKeyFrame() ? Godot.Colors.Red : Godot.Colors.Gray);
  }
}