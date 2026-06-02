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

public readonly record struct FrameData(string id, KeyFrameType t)
{
  public KeyFrameType T { get; } = t;
  public string ID { get; } = id;
}

public class Generator()
{
  public static List<DF.Lib.Tween.Frame<DF.Lib.Position.Position, FrameData>> Rotate(
    string id,
    DF.Lib.Position.Position p,
    DF.Lib.Position.Position q,
    ulong t,
    DF.Lib.Position.Velocity v)
  {
    var (u, f) = Generator._Rotation(p, q, t, v.W);
    if (!f.HasValue)
    {
      return [];
    }

    return [
      new((ulong)u, f.Value, new(id, KeyFrameType.CompletedTurn))
    ];
  }

  /// <summary>
  /// Generates angular movement frame.
  /// </summary>
  /// <param name="p">Source position.</param>
  /// <param name="q">Destination position.</param>
  /// <param name="u">Input time in milliseconds, as float.</param>
  /// <param name="w">Angular velocity.</param>
  /// <returns></returns>
  internal static F _Rotation(
    DF.Lib.Position.Position p,
    DF.Lib.Position.Position q,
    float u,
    float w)
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
  internal static F _Translation(
  DF.Lib.Position.Position p,
  DF.Lib.Position.Position q,
  float u,
  float v)
  {
    if (p == q || v == 0)
    {
      return (u, null);
    }

    u += Math.Max(1, (q.XY - p.XY).Length() / v);
    return (u, q);
  }

  public static List<DF.Lib.Tween.Frame<DF.Lib.Position.Position, FrameData>> Frames(
    string id,
    DF.Lib.Position.Position p,
    ulong t,
    DF.Lib.Position.Velocity v,
    List<Godot.Vector3I> cells)
  {
    if (cells.Count == 0)
    {
      return [];
    }

    float u = (float)t;  // Current time.

    DF.Lib.Position.Position? f;

    List<DF.Lib.Tween.Frame<DF.Lib.Position.Position, FrameData>> fs = [
      new(t, p, new(id, KeyFrameType.None)),
    ];

    for (int i = 0; i < cells.Count; i++)
    {
      Godot.Vector3 qp = DF.Lib.Position.Transformation.ToWorld(cells[i]);

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

      (u, f) = Generator._Rotation(p, q, u, v.W);

      if (f.HasValue)
      {
        fs.Add(new((ulong)Math.Round(u), f.Value, new(id, KeyFrameType.CompletedTurn)));

        // Ensure unit stays aligned during translation.
        q = new(q.P, f.Value.T);
      }

      // Only orient towards the next waypoint if the planar velocity is 0. Do
      // not continue generating rotational frames in this case.
      if (v.XY <= 1e-2)  // Epsilon.
      {
        return fs;
      }

      (u, f) = Generator._Translation(p, q, u, v.XY);

      if (f.HasValue)
      {
        fs.Add(
          new(
            (ulong)Math.Round(u),
            f.Value,
            new(
              id,
              KeyFrameType.ReachedTile | (
                (i == cells.Count - 1) ? KeyFrameType.ReachedGoal : KeyFrameType.None))));
      }

      p = q;
    }
    return fs;
  }
}

public class Path
{
  /// <summary>
  /// Ordered list of waypoint cells (i.e. not real-world positions).
  /// </summary>
  internal List<Godot.Vector3I> _cells = [];

  /// <summary>
  /// Tracks the next waypoint. This property is changed by installing the
  /// <see cref="ReachedTileHandler"/> on the position tween
  /// </summary>
  internal int? _index;
  internal bool _is_looped = false;
  internal string _id = Guid.NewGuid().ToString();

  public string ID() => this._id;

  /// <summary>
  /// Returns the list of cells that have not yet been reached in the current
  /// path. If <see cref="Path._is_looped"/> is set to <c>true</c>, returns
  /// the loop, starting at the next node. 
  /// </summary>
  public List<Godot.Vector3I> Cells()
  {
    if (!this._index.HasValue)
    {
      return [];
    }

    List<Godot.Vector3I> result = [];
    if (!this._is_looped)
    {
      for (int i = this._index.Value; i < this._cells.Count; i++)
      {
        result.Add(this._cells[i]);
      }
    }
    else
    {
      for (int i = 0; i < this._cells.Count; i++)
      {
        result.Add(this._cells[(i + this._index.Value) % this._cells.Count]);
      }
    }
    return result;
  }

  /// <summary>
  /// Sets a new path. Preserves <see cref="Next" /> by prepending to the
  /// path to smooth out unit movement.
  /// </summary>
  public void Merge(List<Godot.Vector3I> cells, bool is_looped = false)
  {
    this._is_looped = is_looped;

    if (cells.Count == 0)
    {
      this._cells = cells;
      this._index = null;
      return;
    }

    Godot.Vector3I? n = this.Next();

    // Preserve current next-node destination if it exists -- we want to make
    // sure that if the unit is currently traveling that it will continue going
    // to the next whole node.
    if (n.HasValue && n.Value != cells[0])
    {
      cells.Insert(0, n.Value);
    }
    this._cells = cells;
    this._index = cells.Count == 0 ? null : 0;
  }

  /// <summary>
  /// Gets the next waypoint for the parent
  /// <see cref="DF.Model.Unit.Base"/> instance.
  /// </summary>
  /// <remarks>
  /// Parent must connect the
  /// <see cref="DF.Lib.Tween.Base{U, W}.KeyframeTriggerEvent"/> event
  /// handler manually.
  /// <example>
  /// <code>
  ///     position.KeyFrameTriggerEvent += path.KeyFrameTriggerEventHandler;
  /// </code>
  /// </example>
  /// </remarks>
  public Godot.Vector3I? Next()
  {
    if (this._index.HasValue && this._index.Value < this._cells.Count)
    {
      return this._cells[this._index.Value];
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
  /// Event handler for the parent <see cref="DF.Model.Unit.Base"/> to
  /// link to the
  /// <see cref="DF.Lib.Tween.Base{U, W}.KeyframeTriggerEvent"/>
  /// instance.
  /// </summary>
  public void ReachedTileHandler(
    object sender,
    DF.Lib.Tween.KeyframeTriggerEventHandlerArgs<DF.Lib.Position.Position, FrameData> e)
  {
    if (e.F.D.T.HasFlag(KeyFrameType.ReachedTile) && e.F.D.ID == this._id)
    {
      this.SetNext();
    }
  }

  /// <summary>
  /// Return a list of <see cref="DF.Lib.Tween.Frame{U, W}"/> movement
  /// frames of the stored path. Callers call this function <b>once</b> before
  /// movement starts and merges into the
  /// <see cref="DF.Lib.Position.Position"/> instance.
  /// </summary>
  /// <remarks>
  /// <example>
  /// <code>
  ///     path.Merge(ps, is_looped: false);
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
  /// <param name="p">The current position of the unit.</param>
  /// <param name="t">The starting timestamp in milliseconds.</param>
  /// <param name="v">The velocity of the unit.</param>
  public List<DF.Lib.Tween.Frame<DF.Lib.Position.Position, FrameData>> Frames(
    DF.Lib.Position.Position p,
    ulong t,
    DF.Lib.Position.Velocity v) => Generator.Frames(this._id, p, t, v, this.Cells());
}
