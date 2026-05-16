using System;
using System.Collections.Generic;

namespace DF.Instances.Components.Abilities;

public partial class Cooldown : Base
{
  /// <summary>
  /// Recharge time of each charge in milliseconds. A value of <c>0</c> is an
  /// ability which can only be triggered once (per charge).
  /// </summary>
  [Godot.Export]
  public ulong RechargePeriod = 0;

  private ulong _last_triggered = 0;

  internal DF.Instances.Tween.Bool.Pulse<bool> _pulse = new();
  internal DF.Instances.Tween.Bool.Step<bool> _charge = new();

  public override void _Ready()
  {
    base._Ready();

    this.AddChild(this._pulse);
    this.AddChild(this._charge);

    this._charge.Add([
      new (this._timer().CurrTick(), true, false)]);

    this._pulse.Init();
    this._charge.Init();

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