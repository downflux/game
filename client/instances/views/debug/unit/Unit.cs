using Godot;

namespace DF.Instances.Debug;

public partial class Unit : Node2D
{
  [Godot.Export]
  public DF.Instances.Unit.Base? Node;

  public override void _Ready()
  {
    base._Ready();

    if (this.Node == null)
    {
      return;
    }

    ((DF.Views.Debug.Components.HealthPool)this.GetNode("HealthPool")).SetNode(((DF.Instances.Components.HealthPool)this.Node.GetNode("HealthPool")));
    ((DF.Views.Debug.Components.Abilities.Cooldown)this.GetNode("Abilities/Fireball")).SetNode(((DF.Instances.Components.Abilities.Cooldown)this.Node.GetNode("Abilities/Fireball")));
    ((DF.Views.Debug.Components.Moveable)this.GetNode("Moveable")).SetNode(((DF.Instances.Components.Moveable)this.Node.GetNode("Moveable")));
  }
}
