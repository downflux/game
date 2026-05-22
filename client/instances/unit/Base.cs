using Godot;

namespace DF.Instances.Unit;

public partial class Base : Node
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
  public DF.Instances.Components.HealthPool HealthPool() => this.GetNode<DF.Instances.Components.HealthPool>("HealthPool");
  public DF.Instances.Components.Moveable Moveable() => this.GetNode<DF.Instances.Components.Moveable>("Moveable");

  internal DF.Lib.Timer.D _timer = () => DF.Instances.Timer.T.S();

  public float Health() => this.HealthPool().Health();
  public bool IsAlive() => this.HealthPool().IsAlive();
}
