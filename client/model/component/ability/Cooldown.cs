using System;
using System.Collections.Generic;

namespace DF.Model.Component.Ability;

public partial class Cooldown : Base
{
  /// <summary>
  /// Recharge time of each charge in milliseconds. A value of <c>0</c> is an
  /// ability which can only be triggered once (per charge).
  /// </summary>
  [Godot.Export]
  public ulong RechargePeriod = 0;

  private ulong _last_triggered = 0;

  internal DF.Lib.Tween.Bool<bool> _pulse = new(DF.Lib.Tween.InterpolationType.Pulse);
  internal DF.Lib.Tween.Bool<bool> _charge = new(DF.Lib.Tween.InterpolationType.Step);

  public override void _Notification(int what)
  {
    base._Notification(what);

    if (what == Godot.GodotObject.NotificationPredelete)
    {
      DF.Model.Tween.Directory.S().Dequeue(this._pulse.ID());
      DF.Model.Tween.Directory.S().Dequeue(this._charge.ID());
    }
  }

  public override void _Ready()
  {
    base._Ready();

    DF.Model.Tween.Directory.S().Enqueue(this._pulse);
    DF.Model.Tween.Directory.S().Enqueue(this._charge);

    this._charge.Add([
      new (this._timer().CurrTick(), true, false)]);
  }

  public ulong Next()
  {
    List<DF.Lib.Tween.Frame<bool, bool>> fs = this._charge.Slice(
      this._timer().CurrTick(),
      this._timer().CurrTick() + this.RechargePeriod);

    foreach (var f in fs)
    {
      if (f.V)
      {
        return f.T;
      }
    }

    return ulong.MaxValue;
  }

  public override bool Trigger()
  {
    // This function can only trigger once per game tick, to prevent situations
    // where multiple callers to a unit may result in invalid attack triggers.
    // This would be effectively an AoE attack, but masked as a single-target
    // trigger.
    if (this._last_triggered == this._timer().CurrTick())
    {
      return false;
    }

    this._last_triggered = this._timer().CurrTick();

    DF.Lib.Tween.Frame<bool, bool>? f = this._charge.Get(this._timer().CurrTick());
    if (f.HasValue && !f.Value.V)
    {
      return false;
    }
    this._pulse.Add([
      new(this._timer().CurrTick(), true, false),
      ]);

    List<DF.Lib.Tween.Frame<bool, bool>> fs = [
      new(this._timer().CurrTick(), false, false)];
    if (this.RechargePeriod > 0)
    {
      fs.Add(new(this._timer().CurrTick() + this.RechargePeriod, true, false));
    }
    this._charge.Merge(this._timer().CurrTick(), fs);
    return true;
  }
}