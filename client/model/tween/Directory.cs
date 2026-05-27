using System.Collections.Generic;

namespace DF.Model.Tween;

/// <summary>
/// Directory of <see cref="DF.Lib.Tween.Base{U, W}"/> instances. 
/// </summary>
/// <remarks>
/// This directory is in charge of updating each tween, which includes raising
/// all <see cref="DF.Lib.Tween.KeyframeTriggerEventHandler{U, W}"/> in the
/// time slice between the last and current engine tick.
/// </remarks>
public partial class Directory : Godot.Node
{
  // TODO(minkezhang): Add per-client update sync timestamp tracker.

  private static Directory? _singleton;

  public static Directory S() => Directory._singleton!;

  private Dictionary<string, DF.Lib.Tween.INode> _tweens = [];
  private DF.Lib.Timer.D _timer = () => DF.Model.Timer.Server.S();

  public override void _Ready()
  {
    base._Ready();

    Directory._singleton = this;
  }

  /// <summary>
  /// Add an instance of a tween to the internal tracker.
  /// </summary>
  /// <remarks>
  /// Call this in parent <see cref="Godot.Node._Ready"/> calls; <c>_Ready</c>
  /// is in post-order traversal, but <see cref="Godot.Node._Process"/>
  /// is in pre-order traversal, meaning that child nodes
  /// (<see cref="Base{U, W}"/> instances) do not have an opportunity to update
  /// their internal cache before starting a tick.
  /// </remarks>
  /// <param name="n"></param>
  public void Enqueue(DF.Lib.Tween.INode n)
  {
    this._tweens[n.ID()] = n;

    // Call this in parent <see cref="Godot.Node._Ready"/> calls; <c>_Ready</c>
    // is in post-order traversal, but <see cref="Godot.Node._Process"/>
    // is in pre-order traversal, meaning that child nodes
    // (<see cref="Base{U, W}"/> instances) do not have an opportunity to update
    // their internal cache before starting a tick.
    n.Flush();
  }

  /// <summary>
  /// Removes the tween from the internal tracker. Call this in the container's
  /// <see cref="Godot.Node._Notification(int what)"/> method, which serves as
  /// Godot's internal node destructor. See
  /// <see href="https://forum.godotengine.org/t/executing-code-on-free/4906/2"/>
  // for more information.
  /// </summary>
  /// <param name="id"></param>
  public void Dequeue(string id)
  {
    this._tweens.Remove(id);
  }

  public override void _Process(double delta)
  {
    base._Process(delta);

    foreach (var (_, n) in this._tweens)
    {
      n.Process(this._timer().PrevTick(), this._timer().CurrTick());
    }
  }
}