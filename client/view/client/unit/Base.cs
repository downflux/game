using Godot;

namespace DF.View.Client.Unit;

public partial class Base : Node2D
{
  [Godot.Export]
  public DF.Model.Unit.Base? Node;

  public void SetNode(DF.Model.Unit.Base n)
  {
    this.Node = n;
    this.GetNode<DF.View.Client.Component.HealthPool>("HealthPool").SetNode(this.Node.GetNode<DF.Model.Component.HealthPool>("HealthPool"));
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

  internal DF.Lib.Timer.D _timer = () => DF.Model.Timer.Server.S();

  public override void _Process(double dt)
  {
    base._Process(dt);

    if (this.Node == null)
    {
      return;
    }

    this.Position = DF.Lib.Position.Transformation.Project(this.Node.Moveable().Position().P);
  }
}
