using System;
using System.Collections.Generic;
using System.Runtime.Intrinsics.Arm;
using Godot;

namespace DF.Lib.Path;

[Flags]
public enum KeyFrameType
{
  None = 0,
  ReachedTile = 1,
  ReachedGoal = 2,
}

public partial class Path
{
  internal List<Godot.Vector3I> _path = [];
  internal int? _index;

  public List<Godot.Vector3I> P() => new List<Godot.Vector3I>(this._path);

  /// <summary>
  /// Return frames of paths (including next).
  /// </summary>
  /// <param name="t"></param>
  /// <returns></returns>
  public List<DF.Lib.Tween.Frame<Godot.Vector3, KeyFrameType>> Frames(ulong t, Godot.Vector3 p, float v)
  {
    float u = (float)t;

    List<DF.Lib.Tween.Frame<Godot.Vector3, KeyFrameType>> fs = [
      new(t, p, KeyFrameType.None),
    ];
    for (int i = 0; i < this._path.Count; i++)
    {
      Godot.Vector3I q = this._path[i];
      Console.WriteLine($"i = {i}, q = {q}");

      u += (p - q).Length() * v;

      fs.Add(
        new(
          (ulong)u,
          new(q.X, q.Y, q.Z),
          KeyFrameType.ReachedTile | (
            (i == this._path.Count - 1) ? KeyFrameType.ReachedGoal : KeyFrameType.None)));

      p = q;
    }
    // TODO(minkezhang): Implement.
    return fs;
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
    DF.Instances.Tween.TriggerEventHandlerArgs<Godot.Vector3, KeyFrameType> e)
  {
    // TODO(minkezhang): Translate Vector3 which may be in the center of a tile
    // to a Vector3I.
    this.SetNext();
  }
}
