using Godot;

namespace DF.Model.Unit;

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
  public DF.Model.Component.HealthPool HealthPool() => this.GetNode<DF.Model.Component.HealthPool>("HealthPool");
  public DF.Model.Component.Moveable Moveable() => this.GetNode<DF.Model.Component.Moveable>("Moveable");
  public DF.Model.Component.Ability.Attack Attack() => this.GetNode<DF.Model.Component.Ability.Attack>("Abilities/Attack");

  internal DF.Lib.Timer.D _timer = () => DF.Model.Timer.Server.S();

  public float Health() => this.HealthPool().Health();
  public bool IsAlive() => this.HealthPool().IsAlive();

  public override void _Ready()
  {
    base._Ready();

    this.Attack().SetSource(this);
  }
}
