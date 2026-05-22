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

    ((DF.View.Debug.Component.HealthPool)this.GetNode("HealthPool")).SetNode(((DF.Model.Component.HealthPool)this.Node.GetNode("HealthPool")));
    ((DF.View.Debug.Component.Ability.Cooldown)this.GetNode("Abilities/Fireball")).SetNode(((DF.Model.Component.Ability.Cooldown)this.Node.GetNode("Abilities/Fireball")));
    ((DF.View.Debug.Component.Moveable)this.GetNode("Moveable")).SetNode(((DF.Model.Component.Moveable)this.Node.GetNode("Moveable")));
  }
}
