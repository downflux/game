using DF.Instances.Timer;
using Godot;
using Microsoft.VisualStudio.TestPlatform.Utilities;
using System;
using System.Collections.Generic;
using System.Numerics;

namespace DF.Instances.Unit;

public partial class Base : Node2D
{
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
  internal DF.Instances.Components.HealthPool _health_component() => this.GetNode<DF.Instances.Components.HealthPool>("HealthPool");
  internal DF.Instances.Components.Moveable _moveable_component() => this.GetNode<DF.Instances.Components.Moveable>("Moveable");

  internal DF.Lib.Timer.D _timer = () => DF.Instances.Timer.T.S();

  public float Health() => this._health_component().Health();
  public bool IsAlive() => this._health_component().IsAlive();

  public override void _Process(double dt)
  {
    base._Process(dt);

    this.GetNode<Godot.ProgressBar>("HPBar").Value = this.Health() / this._health_component().MaxHealth * 100;
    this.Position = DF.Lib.Position.Transformation.Project(this._moveable_component().Position().P);
  }
}
