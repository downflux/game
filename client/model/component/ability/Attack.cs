using System.Collections.Generic;
using DF.Lib.Tween;

namespace DF.Model.Component.Ability;

public partial class Attack : Cooldown
{
  [Godot.Export]
  public float BaseDamage = 10;
  private DF.Model.Unit.Base? _target;
  private bool _loop = false;

  public Attack()
  {
    this._pulse.KeyframeTriggerEvent += this._OnPulseKeyframeTriggerEvent;
  }

  public override void Stop()
  {
    this.SetTarget(null, false);
    base.Stop();
  }

  public void SetTarget(DF.Model.Unit.Base? n, bool is_looped = false)
  {
    this._target = n;
    this._loop = is_looped;
  }

  public override void Enqueue()
  {
    if (this.State() == FSM.Stop)
    {
      return;
    }

    base.Enqueue();
  }

  protected override FSM State()
  {
    if (this._target == null || !this._target.IsAlive())
    {
      return FSM.Stop;
    }

    return base.State();
  }

  private void _OnPulseKeyframeTriggerEvent(object? sender, DF.Lib.Tween.KeyframeTriggerEventHandlerArgs<bool, bool> e)
  {
    if (this.State() == FSM.Stop)
    {
      this.Stop();
      return;
    }
    this._source!.Moveable().SetOrientation(0);
    // TODO(minkezhang): Pause self, set pathing to aim at target, follow, etc. or add to Unit.
    // TODO(minkezhang): Path.Pause(), Path.Resume(), etc. on Next(), insert and then remove from path.
    this._target!.HealthPool().Damage(this.BaseDamage, Component.DamageAttribute.Explosive | Component.DamageAttribute.Fire);
    if (this._loop)
    {
      this.Enqueue();
    }
    else
    {
      this.Stop();
    }
  }
}
