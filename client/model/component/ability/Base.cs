namespace DF.Model.Component.Ability;

public partial class Base : Godot.Node
{
  protected DF.Model.Unit.Base? _source;

  internal DF.Lib.Timer.D _timer = () => DF.Model.Timer.Server.S();

  public virtual void Stop()
  {
  }

  public virtual void Enqueue()
  {
  }

  public void SetSource(DF.Model.Unit.Base? n) => this._source = n;

  protected virtual FSM State()
  {
    if (this._source == null || !this._source.IsAlive())
    {
      return FSM.Stop;
    }
    return FSM.None;
  }
}