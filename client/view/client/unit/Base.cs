using Godot;

namespace DF.Instances.View.Unit;

public partial class Base : Node2D
{
  [Godot.Export]
  public DF.Instances.Unit.Base? Node;

  public void SetNode(DF.Instances.Unit.Base n)
  {
    this.Node = n;
  }

  public override void _Ready()
  {
    base._Ready();

    if (this.Node == null)
    {
      return;
    }

    this.SetNode(this.Node);
  }

  internal DF.Lib.Timer.D _timer = () => DF.Instances.Timer.T.S();

  public override void _Process(double dt)
  {
    base._Process(dt);

    if (this.Node == null)
    {
      return;
    }

    this.GetNode<Godot.ProgressBar>("HPBar").Value = this.Node.Health() / this.Node.HealthPool().MaxHealth * 100;
    this.Position = DF.Lib.Position.Transformation.Project(this.Node.Moveable().Position().P);
  }
}
