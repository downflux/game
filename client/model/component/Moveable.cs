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
      DF.Model.Tween.Directory.S().Dequeue(this._position.ID());
      DF.Model.Tween.Directory.S().Dequeue(this._velocity.ID());
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

    DF.Model.Tween.Directory.S().Enqueue(this._position);
    DF.Model.Tween.Directory.S().Enqueue(this._velocity);

    this._position.KeyFrameTriggerEvent += this._ReachedGoalHandler;
    this._position.KeyFrameTriggerEvent += this._path.ReachedTileHandler;
    this._velocity.KeyFrameTriggerEvent += this._VelocityChangedHandler;
  }

  private void _ReachedGoalHandler(
    object sender,
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
    object sender,
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

  public void Stop() => this.SetPath([]);

  public void SetPath(List<Godot.Vector3I> p, bool is_looped = false)
  {
    if (this._position == null || this._velocity == null)
    {
      return;
    }

    this._path.Merge(p, is_looped);
    this._position.Merge(
      this._timer().CurrTick(),
      this._path.Frames(
       this.Position(),
        this._timer().CurrTick(),
        this.Velocity()));
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