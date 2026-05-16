using System;
using System.Collections.Generic;

namespace DF.Instances.Debug.Tween;

// TODO(minkezhang): Break out into more descriptive subclasses.
public partial class Pulse : DF.Instances.Debug.Tween.Graph<bool, bool>
{
  public Pulse() : base()
  {
    this.Label = "Pulse";
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

    List<DF.Lib.Tween.Frame<bool, bool>> fs = this.Tween.Slice((ulong)xmin, (ulong)xmax);

    if (fs.Count > 0)
    {
      foreach (var f in fs)
      {
        if (!f.IsKeyFrame())
        {
          continue;
        }
        Godot.Vector2I offset = f.V ? new(
            Pulse.Offset(xmin, xmax, this.Dimension.X, f.T),
            0) : new(Pulse.Offset(xmin, xmax, this.Dimension.X, f.T), this.Dimension.Y);

        this.DrawLine(new(offset.X, this.Dimension.Y), offset, Godot.Colors.Green, 1);
        this._DrawPoint(f, offset);
      }
    }

    int curr_tick = Pulse.Offset(xmin, xmax, this.Dimension.X, this._timer().CurrTick());

    this.DrawLine(
      new Godot.Vector2I(curr_tick, 0),
      new Godot.Vector2I(curr_tick, this.Dimension.Y),
      Godot.Colors.Gray,
      1);
  }

  internal void _DrawPoint(DF.Lib.Tween.Frame<bool, bool> f, Godot.Vector2 p)
  {
    (float xmin, float xmax) = (
      ((float)this._timer().CurrTick() - (float)this.WindowSize / 2) < 0 ? 0 : (float)this._timer().CurrTick() - (float)this.WindowSize / 2,
      (float)this._timer().CurrTick() + (float)this.WindowSize / 2);
    this.DrawCircle(p, 2, f.IsKeyFrame() && (f.T >= xmin || f.T <= xmax) ? Godot.Colors.Red : Godot.Colors.Gray);
  }
}