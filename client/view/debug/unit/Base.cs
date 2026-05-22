using Godot;

namespace DF.View.Debug;

public partial class Base : Node2D
{
  [Godot.Export]
  public DF.Model.Unit.Base? Node;

  public override void _Ready()
  {
    base._Ready();

    if (this.Node == null)
    {
      return;
    }

    this.GetNode<DF.View.Debug.Component.HealthPool>("HealthPool").SetNode(this.Node.GetNode<DF.Model.Component.HealthPool>("HealthPool"));
    this.GetNode<DF.View.Debug.Component.Ability.Cooldown>("Abilities/Fireball").SetNode(this.Node.GetNode<DF.Model.Component.Ability.Cooldown>("Abilities/Fireball"));
    this.GetNode<DF.View.Debug.Component.Moveable>("Moveable").SetNode(this.Node.GetNode<DF.Model.Component.Moveable>("Moveable"));
  }
}
