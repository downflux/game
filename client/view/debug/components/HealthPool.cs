namespace DF.Views.Debug.Components;

public partial class HealthPool : Godot.Node2D
{
  [Godot.Export]
  public DF.Instances.Components.HealthPool? Node;

  [Godot.Export]
  public Godot.Vector2I Dimension;

  private DF.Instances.Debug.Tween.Float<bool?> _view = new() { Label = "Health" };

  public override void _Ready()
  {
    base._Ready();

    this._view.Dimension = this.Dimension;
    this.AddChild(this._view);

    if (this.Node == null)
    {
      return;
    }

    this.SetNode(this.Node);
  }

  public void SetNode(DF.Instances.Components.HealthPool n)
  {
    this.Node = n;
    this._view.Tween = this.Node._health;
    this._view.YMax = this.Node.MaxHealth;
  }
}