namespace DF.Views.Debug.Components.Abilities;

public partial class Cooldown : Godot.Node2D
{
  [Godot.Export]
  public DF.Instances.Components.Abilities.Cooldown? Node;

  [Godot.Export]
  public Godot.Vector2I Dimension;

  private DF.Instances.Debug.Tween.Pulse _pulse = new() { Label = "Pulse" };

  // TODO(minkezhang): Add Step tween renderer and add the charge.

  public override void _Ready()
  {
    base._Ready();

    this._pulse.Dimension = this.Dimension;
    this.AddChild(this._pulse);

    if (this.Node == null)
    {
      return;
    }

    this.SetNode(this.Node);
  }

  public void SetNode(DF.Instances.Components.Abilities.Cooldown n)
  {
    this.Node = n;
    this._pulse.Tween = this.Node._pulse;
  }
}