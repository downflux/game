namespace DF.Instances.Components.Abilities;

public partial class Fireball : Cooldown
{
  [Godot.Export]
  public float BaseDamage = 10;

  private DF.Instances.Unit.Base? _target;

  public Fireball()
  {
    this._pulse.KeyFrameTriggerEvent += (object sender, DF.Instances.Tween.TriggerEventHandlerArgs<bool, bool> e) =>
    {
      if (this._target != null)
      {
        // TODO(minkezhang): Pause self, set pathing to aim at target, follow, etc. or add to Unit.
        // TODO(minkezhang): Check if target is alive; if yes, continue attacking.
        this._target.health_component().Damage(this.BaseDamage, Components.DamageAttribute.Explosive | Components.DamageAttribute.Fire);
      }
    };
  }

  public void Attack(DF.Instances.Unit.Base other)  // TODO(minkezhang): loop = false;
  {
    if (!this.Trigger())
    {
      return;
    }

    this._target = other;
  }
}