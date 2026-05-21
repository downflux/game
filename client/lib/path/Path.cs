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
  internal List<Godot.Vector3I> _path = [];
  internal int? _index;

  public List<Godot.Vector3I> P() => new List<Godot.Vector3I>(this._path);

  /// <summary>
  /// Generates angular movement frame.
  /// </summary>
  internal static F GenerateRotationFrame(
    DF.Lib.Position.Position p, DF.Lib.Position.Position q, float u, float w)
  {

    // Angle of q relative to the x-axis in radians.
    float dt = (float)(p.T - q.T) % (float)Math.Tau;

    if (Math.Abs(dt) < 1e-2)  // Epsilon.
    {
      return (u, null);
    }

    if (w == 0)
    {
      return (u + 1, new(p.P, q.T));
    }

    float qt = q.T;

    if (Math.Abs(dt) > Math.PI)
    {
      qt += (float)(Math.Sign(dt) * Math.Tau);
      dt = (float)Math.Tau - Math.Abs(dt);
    }

    u += Math.Max(1, Math.Abs(dt) / w);
    return (u, new(p.P, qt));
  }

  /// <summary>
  /// Generates XY movement frame.
  /// </summary>
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
  /// Return a list of <see cref="DF.Lib.Tween.Frame{U, W}"/> movement
  /// frames of the stored path. Callers call this function <b>once</b> before
  /// movement starts and merges into the
  /// <see cref="DF.Instances.Tween.Position"/> instance.
  /// </summary>
  /// <remarks>
  /// <example>
  /// <code>
  ///     path.Merge(ps);
  /// 
  ///     var fs = path.Frames(
  ///       position.Get(timer.CurrTick())!.Value.V,
  ///       this._timer().CurrTick(),
  ///       v));
  /// 
  ///     position.Merge(timer.CurrTick(), fs);
  /// </code>
  /// </example>
  /// TODO(minkezhang): Add vertical velocity.
  /// </remarks>
  /// <param name="t">The starting timestamp.</param>
  /// <param name="p">The initial position of the unit.</param>
  /// <param name="v">The velocity of the unit.</param>
  /// <returns></returns>
  public List<DF.Lib.Tween.Frame<DF.Lib.Position.Position, KeyFrameType>> Frames(
    DF.Lib.Position.Position p, ulong t, DF.Lib.Position.Velocity v)
  {
    if (!this._index.HasValue)
    {
      return [];
    }

    float u = (float)t;  // Current time.

    DF.Lib.Position.Position? f;

    List<DF.Lib.Tween.Frame<DF.Lib.Position.Position, KeyFrameType>> fs = [
      new(t, p, KeyFrameType.None),
    ];

    for (int i = this._index.Value; i < this._path.Count; i++)
    {
      Godot.Vector3 qp = DF.Lib.Position.Transformation.ToWorld(this._path[i]);

      // The actual rotation of p may be a multiple of 2pi; we want to make
      // sure that the direction of the new waypoint is within 2pi of the
      // current orientation, which means we need to adjust the target
      // orientation (qt).
      float qt = (new Godot.Vector2(qp.X, qp.Y) - p.XY).Angle();
      float dt = p.T - qt;
      int rotations = (int)(Math.Sign(dt) * Math.Floor(Math.Abs(dt) / Math.Tau));

      DF.Lib.Position.Position q = new(qp, rotations * (float)Math.Tau + qt);

      // Edge case -- it is possible that the current position p is already at
      // the first waypoint. Do not generate the trivial additional rotation
      // and translation frames, and skip to the next waypoint (from the
      // current position p).
      if (i == 0 && p.P == q.P)
      {
        continue;
      }

      (u, f) = Path.GenerateRotationFrame(p, q, u, v.W);

      if (f.HasValue)
      {
        fs.Add(new((ulong)Math.Round(u), f.Value, KeyFrameType.CompletedTurn));

        // Ensure unit stays aligned during translation.
        q = new(q.P, f.Value.T);
      }

      // Only orient towards the next waypoint if the planar velocity is 0. Do
      // not continue generating rotational frames in this case.
      if (v.XY <= 1e-2)  // Epsilon.
      {
        return fs;
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
    return fs;
  }

  /// <summary>
  /// Sets a new path. Preserves <see cref="Path.Next" /> by prepending to the
  /// path to smooth out unit movement.
  /// </summary>
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
    this._index = path.Count == 0 ? null : 0;
  }

  /// <summary>
  /// Gets the next waypoint for the parent
  /// <see cref="DF.Instances.Unit.Base"/> instance.
  /// </summary>
  /// <remarks>
  /// Parent must connect the
  /// <see cref="DF.Instances.Tween.Base{U, W}.KeyFrameTriggerEvent"/> event
  /// handler manually.
  /// <example>
  /// <code>
  ///     position.KeyFrameTriggerEvent += path.KeyFrameTriggerEventHandler;
  /// </code>
  /// </example>
  /// </remarks>
  public Godot.Vector3I? Next()
  {
    if (this._index.HasValue && this._index.Value < this._path.Count)
    {
      return this._path[this._index.Value];
    }
    return null;
  }

  /// <summary>
  /// Advances the internal waypoint pointer to the next node.
  /// </summary>
  internal void SetNext()
  {
    this._index = this._index.HasValue ? this._index + 1 : 0;
  }

  /// <summary>
  /// Event handler for the parent <see cref="DF.Instances.Unit.Base"/> to
  /// link to the
  /// <see cref="DF.Instances.Tween.Base{U, W}.KeyFrameTriggerEvent"/>
  /// instance.
  /// </summary>
  public void ReachedTileHandler(
    object sender,
    DF.Instances.Tween.KeyframeTriggerEventHandlerArgs<DF.Lib.Position.Position, KeyFrameType> e)
  {
    if (e.F.D.HasFlag(KeyFrameType.ReachedTile))
    {
      this.SetNext();
    }
  }
}
