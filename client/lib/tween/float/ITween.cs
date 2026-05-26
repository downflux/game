using System.Collections.Generic;

namespace DF.Lib.Tween;

public interface INode
{
  string ID();
  void Process(ulong lb, ulong ub);
  void Flush();
}

public interface ITweenRO<U, W> where U : struct
{
  public Frame<U, W>? Get(ulong t);
  public List<Frame<U, W>> Slice(ulong? lo, ulong? hi);
  public InterpolationType Type();
}

/// <summary>
/// Interface defining a "curve" per
/// <see href="https://www.forrestthewoods.com/blog/tech_of_planetary_annihilation_chrono_cam/" />
/// </summary>
/// <typeparam name="U"></typeparam>
/// <typeparam name="W"></typeparam>
public interface ITween<U, W> : ITweenRO<U, W> where U : struct
{
  public void Add(List<Frame<U, W>> fs);
  public void Remove(List<Frame<U, W>> fs);

  /// <summary>
  /// Returns a keyframe strictly after the input time. If t is beyond the last keyframe, return the current frame.
  /// </summary>
  /// <param name="t"></param>
  /// <returns></returns>
  public Frame<U, W>? Next(ulong t);

  public void Scale(ulong? t, float r);
  public void Cut(ulong t);
  public void Merge(ulong t, List<Frame<U, W>> fs);
  public void Flush();
  public void Clear();
}