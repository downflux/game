namespace DF.Model.Component.Ability;

public partial class Attack : Cooldown
{
  [Godot.Export]
  public float BaseDamage = 10;

  private DF.Model.Unit.Base? _target;
  private bool _loop = false;
  private bool _enqueued = false;  // If can't immediately trigger.

  public Attack()
  {
    this._pulse.KeyframeTriggerEvent += this._OnPulseTrigger;
  }

  public void Stop() => this.SetTarget(null, false);

  public void SetTarget(DF.Model.Unit.Base? n, bool is_looped = false)
  {
    this._target = n;
    this._loop = is_looped;
  }

  public override void Enqueue()
  {
    if (this._target != null && this._target.IsAlive())
    {
      base.Enqueue();
    }
  }

  private void _OnPulseTrigger(object? sender, DF.Lib.Tween.KeyframeTriggerEventHandlerArgs<bool, bool> e)
  {
    if (this._target != null)
    {
      // TODO(minkezhang): Pause self, set pathing to aim at target, follow, etc. or add to Unit.
      // TODO(minkezhang): Check if target is alive; if yes, continue attacking. (if this._loop, this.Attack(this._target).
      // TODO(minkezhang): Path.Pause(), Path.Resume(), etc. on Next(), insert and then remove from path.
      this._target.HealthPool().Damage(this.BaseDamage, Component.DamageAttribute.Explosive | Component.DamageAttribute.Fire);
      if (this._loop && this._target.IsAlive())
      {
        this.Enqueue();
      }
      else
      {
        this.Stop();
      }
    }
  }
}