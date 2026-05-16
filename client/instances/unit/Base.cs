using DF.Instances.Timer;
using Godot;
using Microsoft.VisualStudio.TestPlatform.Utilities;
using System;
using System.Collections.Generic;
using System.Numerics;

namespace DF.Instances.Unit;

public partial class Base : Node2D
{
  [Godot.Export]
  required public float BaseVelocity;

  [Godot.Export]
  required public float BaseAngularVelocity;

  [Godot.Export]
  required public float BaseVerticalVelocity;

  // TODO(minkezhang): Add configurable vz behavior
  //   e.g. VTOL vs. HTOL, walk-only (i.e. hug ground -- ignore vz and assume
  //   linear); VTOL and HTOL --> START | END takeoff.
  // TODO(minkezhang): Change Posiiton curve to include START | END takeoff
  //   XOR enum.
  // TODO(minkezhang): Consider move modes for point-to-point air movement,
  //   vs. continuous turning (i.e. spline) (but only air, not ground, which
  //   will ignore collision detection (otherwise this becomes 3D boids
  //   behavior).
  // TODO(minkezhang): Add Attack(cooldown) as a separate component.
  // TODO(minkezhang): Clean up namespaces.
  internal DF.Instances.Components.HealthPool health_component() => this.GetNode<DF.Instances.Components.HealthPool>("HealthPool");
  private DF.Instances.Tween.Position position_tween() => this.GetNode<DF.Instances.Tween.Position>("Position");
  private DF.Instances.Tween.Velocity velocity_tween() => this.GetNode<DF.Instances.Tween.Velocity>("Velocity");
  internal DF.Lib.Timer.D _timer = () => DF.Instances.Timer.T.S();
  internal DF.Lib.Path.Path _path = new();

  /// <summary>
  /// When reaching the end of a set of waypoints, instructs the unit to loop
  /// back to the beginning if set to true.
  /// </summary>
  private bool _loop = false;

  public override void _Ready()
  {
    base._Ready();

    this.velocity_tween().Add(
      [
        new(
          this._timer().CurrTick(),
          new(this.BaseVelocity, this.BaseVerticalVelocity, this.BaseAngularVelocity),
          false),
      ]);
    this.position_tween().Add(
      [
        new(
          this._timer().CurrTick(),
          new(
            new(
              this.Position.X,
              this.Position.Y,
              0),
            0),
            DF.Lib.Path.KeyFrameType.ReachedTile),
      ]);

    this.position_tween().Init();
    this.velocity_tween().Init();

    this.position_tween().KeyFrameTriggerEvent += this.PathLoopHandler;
    this.position_tween().KeyFrameTriggerEvent += this._path.KeyFrameTriggerEventHandler;
    this.velocity_tween().KeyFrameTriggerEvent += this.SetVelocityKeyFrameTriggerEventHandler;
  }

  private void FireHandler(object sender,
    Tween.TriggerEventHandlerArgs<bool, bool> e)
  {
    // TODO(minkezhang): Debug.
    this.health_component().Damage(10, Components.DamageAttribute.Bullet);
  }

  private void PathLoopHandler(
    object sender,
    Tween.TriggerEventHandlerArgs<Lib.Position.Position, Lib.Path.KeyFrameType> e)
  {
    if (e.F.D.HasFlag(Lib.Path.KeyFrameType.ReachedGoal))
    {
      this.SetPath(this._loop ? this._path.P() : [], this._loop);
    }
  }

  private void SetVelocityKeyFrameTriggerEventHandler(
    object sender,
    DF.Instances.Tween.TriggerEventHandlerArgs<DF.Lib.Position.Velocity, bool> e)
  {
    if (e.F.IsKeyFrame())
    {
      this.position_tween().Merge(
        this._timer().CurrTick(),
        this._path.Frames(
        this.Position4D(),
        this._timer().CurrTick(),
        e.F.V));
    }
  }

  /// <summary>
  /// Calculates the "true" 3D position of the isometric unit.
  /// </summary>
  public DF.Lib.Position.Position Position4D() => this.position_tween().Get(this._timer().CurrTick())!.Value.V;

  public float Health() => this.health_component().Health();
  public DF.Lib.Position.Velocity Velocity() => this.velocity_tween().Get(this._timer().CurrTick())!.Value.V;

  public void SetPath(List<Godot.Vector3I> p, bool loop = false)
  {
    this._path.Merge(p);
    this.position_tween().Merge(
      this._timer().CurrTick(),
      this._path.Frames(
        this.Position4D(),
        this._timer().CurrTick(),
        this.Velocity()));
    this._loop = loop;
  }

  public void SetVelocity(DF.Lib.Position.Velocity v)
  {
    Godot.GD.Print($"DEBUG(Base.cs): setting v = {v}");
    // BUG(minkezhang): Increasing SetVelocity() very fast seems to break something.
    if (v.XY < 0 || v.W < 0)  // Epsilon.
    {
      return;
    }
    this.velocity_tween().Add([
      new(this._timer().CurrTick(), v, false),
    ]);
  }

  public override void _Process(double dt)
  {
    base._Process(dt);

    this.GetNode<Godot.ProgressBar>("HPBar").Value = this.Health() / this.health_component().MaxHealth * 100;

    var p = this.Position4D();
    this.Position = new Godot.Vector2(p.P.X, p.P.Y);
  }
}
