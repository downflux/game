using System;
using System.Collections.Generic;
using System.Xml.Serialization;
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
    return ymax - ymin < 1 ? (ymin - 1, ymax + 1) : (ymin, ymax);
  }

  private void _DrawLine(
    float xmin,
    float xmax,
    float ymin,
    float ymax,
    DF.Lib.Tween.Frame<float, W> curr,
    DF.Lib.Tween.Frame<float, W>? next)
  {
    if (this.Tween == null)
    {
      return;
    }

    Godot.Vector2I offset_f = new(
      Float<W>.Offset(xmin, xmax, this.Dimension.X, curr.T),
      -Float<W>.Offset(ymin, ymax, this.Dimension.Y, curr.V));
    Godot.Vector2I? offset_g = next.HasValue ? new(
      Float<W>.Offset(xmin, xmax, this.Dimension.X, next.Value.T),
      -Float<W>.Offset(ymin, ymax, this.Dimension.Y, next.Value.V)) : null;
    Godot.Vector2 p = new Godot.Vector2I(0, this.Dimension.Y) + offset_f;
    Godot.Vector2? q = null;
    switch (this.Tween.Type())
    {
      case DF.Lib.Tween.InterpolationType.Linear:
        if (offset_g.HasValue)
        {
          q = new Godot.Vector2I(0, this.Dimension.Y) + offset_g.Value;
        }
        break;
      case DF.Lib.Tween.InterpolationType.Step:
        if (offset_g.HasValue)
        {
          q = new Godot.Vector2I(0, this.Dimension.Y) + new Godot.Vector2I(offset_g.Value.X, offset_f.Y);
        }
        break;
      case DF.Lib.Tween.InterpolationType.Pulse:
        q = new Godot.Vector2I(0, this.Dimension.Y) + new Godot.Vector2I(offset_f.X, 0);
        break;
    }
    if (q.HasValue)
    {
      this.DrawLine(p, q.Value, Godot.Colors.Green, 1);
    }

    this._DrawPoint(curr, p);
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
      for (var i = 1; i <= fs.Count; i++)
      {

        DF.Lib.Tween.Frame<float, W>? g = i == fs.Count ? null : fs[i];
        this._DrawLine(xmin, xmax, ymin, ymax, f, g);
        if (g.HasValue)
        {
          f = g.Value;
        }
      }
    }

    int curr_tick = Float<W>.Offset(xmin, xmax, this.Dimension.X, this._timer().CurrTick());

    // Draw current tick line.
    this.DrawLine(
      new Godot.Vector2I(curr_tick, 0),
      new Godot.Vector2I(curr_tick, this.Dimension.Y),
      Godot.Colors.Gray,
      1);
  }

  private void _DrawPoint(DF.Lib.Tween.Frame<float, W> f, Godot.Vector2 p)
  {
    (float xmin, float xmax) = (
      ((float)this._timer().CurrTick() - (float)this.WindowSize / 2) < 0 ? 0 : (float)this._timer().CurrTick() - (float)this.WindowSize / 2,
      (float)this._timer().CurrTick() + (float)this.WindowSize / 2);
    this.DrawCircle(p, 2, f.IsKeyFrame() && (f.T >= xmin || f.T <= xmax) ? Godot.Colors.Red : Godot.Colors.Gray);
  }
}