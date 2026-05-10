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
  // TODO(minkezhang): Add orientation debug line.
  private DF.Instances.Tween.HP hp() => this.GetNode<DF.Instances.Tween.HP>("HP");
  private DF.Instances.Tween.Position position() => this.GetNode<DF.Instances.Tween.Position>("Position");
  private DF.Instances.Tween.Velocity velocity() => this.GetNode<DF.Instances.Tween.Velocity>("Velocity");
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

    this.hp().Add(
      [
        new(this._timer().CurrTick(), this.MaxHP, false),
      ], true);
    this.velocity().Add(
      [
        new(
          this._timer().CurrTick(),
          new(this.BaseVelocity, this.BaseVerticalVelocity, this.BaseAngularVelocity),
          false),
      ], true);
    this.position().Add(
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

    this.hp().WatchPoints[this.MaxHP] = DF.Lib.Tween.EdgeType.RisingEdge;

    this.position().KeyFrameTriggerEvent += (t, e) =>
    {
      if (e.F.D.HasFlag(Lib.Path.KeyFrameType.ReachedGoal))
      {
        this.SetPath(this._loop ? this._path.P() : [], this._loop);
      }
    };
    this.position().KeyFrameTriggerEvent += this._path.KeyFrameTriggerEventHandler;
  }

  /// <summary>
  /// Calculates the "true" 3D position of the isometric unit.
  /// </summary>
  public DF.Lib.Position.Position Position4D() => this.position().Get(this._timer().CurrTick())!.Value.V;

  public float HP() => Godot.Mathf.Clamp(this.hp().Get(this._timer().CurrTick())!.Value.V, 0, this.MaxHP);
  public DF.Lib.Position.Velocity Velocity() => this.velocity().Get(this._timer().CurrTick())!.Value.V;

  public void SetPath(List<Godot.Vector3I> p, bool loop = false)
  {
    this._path.Merge(p);
    this.position().Merge(
      this._timer().CurrTick(),
      this._path.Frames(
        this.Position4D(),
        this._timer().CurrTick(),
        this.Velocity()));
    this._loop = loop;
  }

  public void SetHP(float v, ulong dt)
  {
    if (v > this.MaxHP || v < 0)
    {
      throw new ArgumentOutOfRangeException(
        nameof(v),
        $"setting HP {v} outside of valid range [{0}, {this.MaxHP}]");
    }

    this.hp().Add([
      new(this._timer().CurrTick() + dt, v, false),
    ]);
  }

  public void SetVelocity(DF.Lib.Position.Velocity v)
  {
    this.velocity().Add([
      new(this._timer().CurrTick(), v, false),
    ]);
    this.position().Merge(
      this._timer().CurrTick(),
      this._path.Frames(
      this.Position4D(),
      this._timer().CurrTick(),
      v));
  }

  public override void _Process(double dt)
  {
    base._Process(dt);

    this.GetNode<Godot.ProgressBar>("HPBar").Value = this.HP() / this.MaxHP * 100;

    var p = this.Position4D();
    this.Position = new Godot.Vector2(p.P.X, p.P.Y);
  }
}
