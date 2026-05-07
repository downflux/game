using System;
using System.Collections.Generic;

namespace DF.Lib.Path;

using F = (float T, DF.Lib.Position.Position? P);

[Flags]
public enum KeyFrameType
{
  None = 0,
  ReachedTile = 1,
  ReachedGoal = 2,
  CompletedTurn = 4,
}

public partial class Path
{
  public static Godot.Vector3 ToWorld(Godot.Vector3I c)
  {
    // TODO(minkezhang): Return grid transformation.
    return (Godot.Vector3)c;
  }

  internal List<Godot.Vector3I> _path = [];
  internal int? _index;

  public List<Godot.Vector3I> P() => new List<Godot.Vector3I>(this._path);

  // Generates angular movement.
  internal static F GenerateRotationFrame(
    DF.Lib.Position.Position p, DF.Lib.Position.Position q, float u, float w)
  {
    // Angle of q relative to the x-axis in radians.
    float dt = p.T - q.T;

    // Rotate.
    if (Math.Abs(dt) < 1e-2) // epsilon && w > 0)  // epsilon
    {
      return (u, null);
    }

    if (w == 0)
    {
      return (u + 1, new(p.P, q.T));
    }

    if (Math.Abs(dt) > Math.PI)
    {
      dt = (float)(2 * Math.PI) - Math.Abs(dt);
    }

    u += Math.Max(1, Math.Abs(dt) / w);
    return (u, new(p.P, q.T));
  }

  // Generates XY movement.
  internal static F GenerateTranslationFrame(
  DF.Lib.Position.Position p, DF.Lib.Position.Position q, float u, float v)
  {
    if (p == q || v == 0)
    {
      return (u, null);
    }

    u += Math.Max(1, (q.XY - p.XY).Length() / v);
    return (u, q);
  }

  /// <summary>
  /// Return frames of paths (including next).
  /// </summary>
  /// <remarks>
  /// TODO(minkezhang): Add vertical velocity.
  /// </remarks>
  /// <param name="t">The starting timestamp.</param>
  /// <param name="p">The initial position of the unit.</param>
  /// <param name="v">The velocity of the unit.</param>
  /// <param name="w">The angular velocity of the unit.</param>
  /// <returns></returns>
  public List<DF.Lib.Tween.Frame<DF.Lib.Position.Position, KeyFrameType>> Frames(
    DF.Lib.Position.Position p, ulong t, DF.Lib.Position.Velocity v)
  {
    if (!this._index.HasValue)
    {
      return [];
    }

    float u = (float)t;  // Current time.

    DF.Lib.Position.Position? f = null;

    List<DF.Lib.Tween.Frame<DF.Lib.Position.Position, KeyFrameType>> fs = [
      new(t, p, KeyFrameType.None),
    ];
    for (int i = this._index.Value; i < this._path.Count; i++)
    {
      Godot.Vector3 qp = Path.ToWorld(this._path[i]);
      DF.Lib.Position.Position q = new(
        qp, (new Godot.Vector2(qp.X, qp.Y) - p.XY).Angle());

      (u, f) = Path.GenerateRotationFrame(p, q, u, v.W);

      if (f.HasValue)
      {
        fs.Add(new((ulong)Math.Round(u), f.Value, KeyFrameType.CompletedTurn));
      }

      (u, f) = Path.GenerateTranslationFrame(p, q, u, v.XY);

      if (f.HasValue)
      {
        fs.Add(
          new(
            (ulong)Math.Round(u),
            f.Value,
            KeyFrameType.ReachedTile | (
              (i == this._path.Count - 1) ? KeyFrameType.ReachedGoal : KeyFrameType.None)));
      }

      p = q;
    }
    return fs; // Path.MergeFrames(fs);
  }

  public void Merge(List<Godot.Vector3I> path)
  {
    if (path.Count == 0)
    {
      this._path = path;
      this._index = null;
      return;
    }

    Godot.Vector3I? n = this.Next();

    // Preserve current next-node destination if it exists -- we want to make
    // sure that if the unit is currently traveling that it will continue going
    // to the next whole node.
    if (n.HasValue && n.Value != path[0])
    {
      path.Insert(0, n.Value);
    }
    this._path = path;
    this._index = 0;
  }

  public Godot.Vector3I? Next()
  {
    if (this._index.HasValue && this._index.Value < this._path.Count)
    {
      return this._path[this._index.Value];
    }
    return null;
  }

  public void SetNext()
  {
    this._index = this._index.HasValue ? this._index + 1 : 0;
  }

  public void KeyFrameTriggerEventHandler(
    object sender,
    DF.Instances.Tween.TriggerEventHandlerArgs<DF.Lib.Position.Position, KeyFrameType> e)
  {
    // TODO(minkezhang): Translate e.F.V.P (a Vector3 value) to a Vector3I.
    if (e.F.D.HasFlag(KeyFrameType.ReachedTile))
    {
      this.SetNext();
    }
  }
}
