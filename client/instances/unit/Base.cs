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
  required public float MaxHP;

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
  private DF.Instances.Tween.HP hp_tween() => this.GetNode<DF.Instances.Tween.HP>("HP");
  private DF.Instances.Tween.Position position_tween() => this.GetNode<DF.Instances.Tween.Position>("Position");
  private DF.Instances.Tween.Velocity velocity_tween() => this.GetNode<DF.Instances.Tween.Velocity>("Velocity");
  private DF.Instances.Tween.Pulse weapon_tween() => this.GetNode<DF.Instances.Tween.Pulse>("Weapon");
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

    this.hp_tween().Add(
      [
        new(this._timer().CurrTick(), this.MaxHP, false),
      ], true);
    this.velocity_tween().Add(
      [
        new(
          this._timer().CurrTick(),
          new(this.BaseVelocity, this.BaseVerticalVelocity, this.BaseAngularVelocity),
          false),
      ], true);
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
      ], true);

    this.hp_tween().WatchPoints[this.MaxHP] = DF.Lib.Tween.EdgeType.RisingEdge;

    this.position_tween().KeyFrameTriggerEvent += this.PathLoopHandler;
    this.position_tween().KeyFrameTriggerEvent += this._path.KeyFrameTriggerEventHandler;
    this.velocity_tween().KeyFrameTriggerEvent += this.SetVelocityKeyFrameTriggerEventHandler;
    this.weapon_tween().KeyFrameTriggerEvent += this.FireHandler;
  }

  private void FireHandler(object sender,
    Tween.TriggerEventHandlerArgs<bool, bool> e)
  {
    // TODO(minkezhang): Debug.
    this.IncrementHP(10, 0);
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

  public float HP() => Godot.Mathf.Clamp(this.hp_tween().Get(this._timer().CurrTick())!.Value.V, 0, this.MaxHP);
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

  public void Fire()
  {
    this.weapon_tween().Add([
      new(this._timer().CurrTick(), true, false),
    ]);
  }

  public void IncrementHP(float v, ulong dt)
  {
    if (v > this.MaxHP || v < 0)
    {
      throw new ArgumentOutOfRangeException(
        nameof(v),
        $"setting HP {v} outside of valid range [{0}, {this.MaxHP}]");
    }

    this.hp_tween().Add([
      new(this._timer().CurrTick(), this.HP(), false),
      new(this._timer().CurrTick() + dt, this.HP() + v, false),
    ]);
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

    this.GetNode<Godot.ProgressBar>("HPBar").Value = this.HP() / this.MaxHP * 100;

    var p = this.Position4D();
    this.Position = new Godot.Vector2(p.P.X, p.P.Y);
  }
}
