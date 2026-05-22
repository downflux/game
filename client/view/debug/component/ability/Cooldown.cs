namespace DF.View.Debug.Component.Ability;

public partial class Cooldown : Godot.Node2D
{
  [Godot.Export]
  public DF.Model.Component.Ability.Cooldown? Node;

  [Godot.Export]
  public Godot.Vector2I Dimension;

  private DF.View.Debug.Tween.Float<bool> _pulse = new() { Label = "Pulse" };
  private DF.View.Debug.Tween.Float<bool> _charge = new()
  {
    Label = "Charge",
    YMax = 2,
    YMin = -1,
  };

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

  public void SetNode(DF.Model.Component.Ability.Cooldown n)
  {
    this.Node = n;
    this._pulse.Tween = new DF.View.Debug.Tween.Bool.ToFloat(this.Node._pulse);
    this._charge.Tween = new DF.View.Debug.Tween.Bool.ToFloat(this.Node._charge);
  }
}