using System.Collections.Generic;
using System.Runtime.InteropServices.Marshalling;
using Godot;

namespace DF.Model.Component.Ability;

public partial class Cooldown : Base
{
  /// <summary>
  /// Recharge time of each charge in milliseconds. A value of <c>0</c> is an
  /// ability which can only be triggered once (per charge).
  /// </summary>
  [Godot.Export]
  public ulong RechargePeriod = 0;

  /// <summary>
  /// An ability can only trigger once per game tick, to prevent situations
  /// where multiple callers to a unit may result in invalid attack triggers.
  /// This would be effectively an AoE attack, but masked as a single-target
  /// trigger.
  /// </summary>
  private ulong _last_triggered = 0;

  private bool _queued = false;

  internal DF.Lib.Tween.Bool<bool> _pulse = new(DF.Lib.Tween.InterpolationType.Pulse);
  internal DF.Lib.Tween.Bool<bool> _ready = new(DF.Lib.Tween.InterpolationType.Step);

  public override void _Notification(int what)
  {
    base._Notification(what);

    if (what == Godot.GodotObject.NotificationPredelete)
    {
      DF.Model.Tween.Directory.S().Remove(this._pulse.ID());
      DF.Model.Tween.Directory.S().Remove(this._ready.ID());
    }
  }

  public override void _Ready()
  {
    base._Ready();

    DF.Model.Tween.Directory.S().Add(this._pulse);
    DF.Model.Tween.Directory.S().Add(this._ready);

    this._ready.KeyframeTriggerEvent += this._OnReadyKeyFrameTriggerEvent;

    this._ready.Add([
      new (this._timer().CurrTick(), true, false)]);
  }

  private void _OnReadyKeyFrameTriggerEvent(
    object? sender,
    DF.Lib.Tween.KeyframeTriggerEventHandlerArgs<bool, bool> e)
  {
    if (this._queued && e.F.V)
    {
      this._queued = false;
      this.Enqueue();
    }
  }

  protected override FSM State()
  {
    if (base.State() == FSM.Stop)
    {
      return base.State();
    }

    if (this._IsReady() && this._last_triggered != this._timer().CurrTick())
    {
      return FSM.Ready;
    }
    if (this._queued)
    {
      return FSM.Queued;
    }
    return FSM.Cooldown;
  }

  private bool _IsReady() => this._ready.Get(this._timer().CurrTick())!.Value.V;

  /// <summary>
  /// Returns game tick at which this ability can be used again.
  /// </summary>
  public ulong Next()
  {
    List<DF.Lib.Tween.Frame<bool, bool>> fs = this._ready.Slice(
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

  public override void Enqueue()
  {
    switch (this.State())
    {
      case FSM.Cooldown:
        this._queued = true;
        return;
      case FSM.None:
      case FSM.Ready:
        this._Trigger();
        return;
    }
    base.Enqueue();
  }

  private void _Trigger()
  {
    // This function can only trigger once per game tick, to prevent situations
    // where multiple callers to a unit may result in invalid attack triggers.
    // This would be effectively an AoE attack, but masked as a single-target
    // trigger.
    if (this._last_triggered == this._timer().CurrTick())
    {
      return;
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

    this._ready.Merge(this._timer().CurrTick(), fs);

    return;
  }
}