using Godot;

namespace DF.View.Client.Component;

public partial class HealthPool : ProgressBar
{
  [Godot.Export]
  public DF.Model.Component.HealthPool? Node;

  public override void _Ready()
  {
    base._Ready();

    if (this.Node == null)
    {
      return;
    }

    this.SetNode(this.Node);
  }

  public void SetNode(DF.Model.Component.HealthPool n)
  {
    this.Node = n;
  }

  public override void _Process(double delta)
  {
    base._Process(delta);

    if (this.Node == null)
    {
      return;
    }
    this.Value = this.Node.Health() / this.Node.MaxHealth * 100;
  }
}
