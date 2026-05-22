namespace DF.Model.Component.Ability;

public partial class Base : Godot.Node
{
  internal DF.Lib.Timer.D _timer = () => DF.Model.Timer.Server.S();

  public virtual bool Trigger() => false;
}