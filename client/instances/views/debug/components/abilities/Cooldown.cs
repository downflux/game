namespace DF.Views.Debug.Components.Abilities;

public partial class Cooldown : Godot.Node2D
{
  [Godot.Export]
  public DF.Instances.Components.Abilities.Cooldown? Node;

  [Godot.Export]
  public Godot.Vector2I Dimension;

  private DF.Instances.Debug.Tween.Pulse _pulse = new() { Label = "Pulse" };
  private DF.Instances.Debug.Tween.Float<bool> _charge = new()
  {
    Label = "Charge",
    YMax = 1,
  };

  // TODO(minkezhang): Add Step tween renderer and add the charge.

  public override void _Ready()
  {
    base._Ready();

    this._pulse.Dimension = this.Dimension;
    this._charge.Dimension = this.Dimension;
    this._charge.Position = new(this.Dimension.X, 0);
    this.AddChild(this._pulse);
    this.AddChild(this._charge);

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
    this._charge.Tween = new DF.Instances.Debug.Tween.ToFloat(this.Node._charge);
  }
}