namespace DF.Lib.Command;

public interface IAttack
{
  void Stop();
  void SetTarget(DF.Model.Unit.Base target, bool is_looped = false);
  DF.Model.Component.Ability.FSM State();
  void AddIsReadyHandler();
  void RemoveIsReadyHandler();
  void Enqueue();
}

public class Attack : Base
{
  private IAttack _ability;
  private DF.Model.Unit.Base _source;
  private DF.Model.Unit.Base _target;

  public Attack(IAttack ability, DF.Model.Unit.Base source, DF.Model.Unit.Base target)
  {
    this._ability = ability;
    this._source = source;
    this._target = target;

    /// this._ability.AddIsReadyHandler(...)
  }

  ~Attack()
  {
  }

  public override void Execute()
  {
    if (this._source.IsAlive() && this._target.IsAlive())
    {
    }
  }
}