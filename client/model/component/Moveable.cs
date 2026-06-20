using System.Collections.Generic;
using Godot;

namespace DF.Model.Component;

public partial class Moveable : Node
{
  [Godot.Export]
  required public float PlanarVelocity;

  [Godot.Export]
  required public float AngularVelocity;

  [Godot.Export]
  required public float VerticalVelocity;

  internal DF.Lib.Tween.Base<DF.Lib.Position.Position, DF.Lib.Path.FrameData> _position = new(
    DF.Lib.Tween.InterpolationType.Linear);
  internal DF.Lib.Tween.Base<DF.Lib.Position.Velocity, bool?> _velocity = new(
    DF.Lib.Tween.InterpolationType.Step);

  internal DF.Lib.Path.Path _path = new();

  /// <summary>
  /// When reaching the end of a set of waypoints, instructs the unit to loop
  /// back to the beginning if set to true.
  /// </summary>
  private bool _loop = false;

  internal DF.Lib.Timer.D _timer = () => DF.Model.Timer.Server.S();

  public override void _Notification(int what)
  {
    base._Notification(what);

    if (what == Godot.GodotObject.NotificationPredelete)
    {
      DF.Model.Tween.Directory.S().Remove(this._position.ID());
      DF.Model.Tween.Directory.S().Remove(this._velocity.ID());
    }
  }

  public override void _Ready()
  {
    base._Ready();

    this._velocity.Add(
      [
        new(
          this._timer().CurrTick(),
          new(this.PlanarVelocity, this.VerticalVelocity, this.AngularVelocity),
          false),
      ]);
    this._position.Add(
      [
        new(
          this._timer().CurrTick(),
          new(),
          new("", DF.Lib.Path.KeyFrameType.None)),
      ]);

    DF.Model.Tween.Directory.S().Add(this._position);
    DF.Model.Tween.Directory.S().Add(this._velocity);

    this._position.KeyframeTriggerEvent += this._ReachedGoalHandler;
    this._position.KeyframeTriggerEvent += this._path.ReachedTileHandler;
    this._velocity.KeyframeTriggerEvent += this._VelocityChangedHandler;
  }

  private void _ReachedGoalHandler(
    object? sender,
    DF.Lib.Tween.KeyframeTriggerEventHandlerArgs<DF.Lib.Position.Position, DF.Lib.Path.FrameData> e)
  {
    if (e.F.D.T.HasFlag(Lib.Path.KeyFrameType.ReachedGoal) && e.F.D.ID == this._path.ID())
    {
      if (this._loop)
      {
        this.SetPath(this._path.Cells(), true);
      }
      else
      {
        this.Stop();
      }
    }
  }

  private void _VelocityChangedHandler(
    object? sender,
    DF.Lib.Tween.KeyframeTriggerEventHandlerArgs<DF.Lib.Position.Velocity, bool?> e)
  {
    if (e.F.IsKeyFrame())
    {
      this._position.Merge(
        this._timer().CurrTick(),
        this._path.Frames(
        this.Position(),
        this._timer().CurrTick(),
        e.F.V));
    }
  }

  public void Stop()
  {
    Godot.GD.Print($"DEBUG(Moveable.cs): stop");

    this.SetPath([]);
  }

  public void SetOrientation(float theta)
  {
    if (this._position == null || this._velocity == null)
    {
      return;
    }

    this._path.Merge([], false);
    this._loop = false;

    var n = this._position.Next(this._timer().CurrTick());
    var t = n.HasValue ? n.Value.T : this._timer().CurrTick();
    var p = n.HasValue ? n.Value.V : this.Position();
    var v = this._velocity.Get(t)!.Value.V;

    DF.Lib.Position.Position q = new(p.P, DF.Lib.Path.Generator.Theta(p, theta));
    var fs = DF.Lib.Path.Generator.Rotate("", p, q, t, v);
    this._position.Merge(t, fs);
  }

  public void SetPath(List<Godot.Vector3I> path, bool is_looped = false)
  {
    if (this._position == null || this._velocity == null)
    {
      return;
    }

    var n = this._position.Next(this._timer().CurrTick());
    var t = n.HasValue ? n.Value.T : this._timer().CurrTick();
    var p = n.HasValue ? n.Value.V : this.Position();
    var v = this._velocity.Get(t)!.Value.V;

    this._path.Merge(path, is_looped);
    var fs = this._path.Frames(p, t, v);

    // TODO(minkezhang): Stop at next waypoint -- queue this move for the next
    // TileReached handler?
    this._path.Merge(path, is_looped);
    this._position.Merge(t, fs);
    this._loop = is_looped;
  }

  public void SetVelocity(DF.Lib.Position.Velocity v)
  {
    Godot.GD.Print($"DEBUG(Moveable.cs): setting v = {v}");
    // BUG(minkezhang): Increasing SetVelocity() very fast seems to break something.
    if (v.XY < 0 || v.W < 0)  // Epsilon.
    {
      return;
    }
    this._velocity.Add([
      new(this._timer().CurrTick(), v, null),
    ]);
  }

  public DF.Lib.Position.Position Position() => this._position.Get(this._timer().CurrTick())!.Value.V;
  public DF.Lib.Position.Velocity Velocity() => this._velocity.Get(this._timer().CurrTick())!.Value.V;
}