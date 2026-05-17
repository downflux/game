using System;
using System.Collections.Generic;
using Godot;

namespace DF.Instances.Debug.Tween;

public partial class Float<W> : DF.Instances.Debug.Tween.Graph<float, W>
{
  public float? YMin;
  public float? YMax;

  internal (float YMin, float YMax) YRange(List<DF.Lib.Tween.Frame<float, W>> fs)
  {
    if (this.YMax.HasValue)
    {
      return (this.YMin ?? 0, this.YMax.Value);
    }

    (float ymin, float ymax) = (float.PositiveInfinity, float.NegativeInfinity);
    foreach (DF.Lib.Tween.Frame<float, W> f in fs)
    {
      (ymin, ymax) = (Math.Min(ymin, f.V), Math.Max(ymax, f.V));

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

    List<DF.Lib.Tween.Frame<float, W>> fs = this.Tween.Slice((ulong)xmin, (ulong)xmax);

    (float ymin, float ymax) = this.YRange(fs);

    if (fs.Count > 0)
    {
      DF.Lib.Tween.Frame<float, W> f = fs[0];
      for (var i = 1; i < fs.Count; i++)
      {
        DF.Lib.Tween.Frame<float, W> g = fs[i];

        Godot.Vector2I offset_f = new(
          Float<W>.Offset(xmin, xmax, this.Dimension.X, f.T),
          -Float<W>.Offset(ymin, ymax, this.Dimension.Y, f.V));
        Godot.Vector2I offset_g = new(
          Float<W>.Offset(xmin, xmax, this.Dimension.X, g.T),
          -Float<W>.Offset(ymin, ymax, this.Dimension.Y, g.V));
        Godot.Vector2 p = new Godot.Vector2I(0, this.Dimension.Y) + offset_f;
        Godot.Vector2 q = p;
        switch (this.Tween.Type())
        {
          case DF.Lib.Tween.InterpolationType.Linear:
            q = new Godot.Vector2I(0, this.Dimension.Y) + offset_g;
            break;
          case DF.Lib.Tween.InterpolationType.Step:
            q = new Godot.Vector2I(0, this.Dimension.Y) + new Godot.Vector2I(offset_g.X, offset_f.Y);
            break;
        }

        this.DrawLine(p, q, Godot.Colors.Green, 1);
        this._DrawPoint(f, p);
        if (i == fs.Count - 1)  // Draw last point.
        {
          this._DrawPoint(g, q);
        }

        f = g;
      }
    }

    int curr_tick = Float<W>.Offset(xmin, xmax, this.Dimension.X, this._timer().CurrTick());

    this.DrawLine(
      new Godot.Vector2I(curr_tick, 0),
      new Godot.Vector2I(curr_tick, this.Dimension.Y),
      Godot.Colors.Gray,
      1);
  }

  internal void _DrawPoint(DF.Lib.Tween.Frame<float, W> f, Godot.Vector2 p)
  {
    (float xmin, float xmax) = (
      ((float)this._timer().CurrTick() - (float)this.WindowSize / 2) < 0 ? 0 : (float)this._timer().CurrTick() - (float)this.WindowSize / 2,
      (float)this._timer().CurrTick() + (float)this.WindowSize / 2);
    this.DrawCircle(p, 2, f.IsKeyFrame() && (f.T >= xmin || f.T <= xmax) ? Godot.Colors.Red : Godot.Colors.Gray);
  }
}