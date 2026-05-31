using System;
using System.Collections.Generic;
using Godot;

namespace DF.Model.Component;

[System.Flags]
public enum DamageAttribute
{
  None = 0,
  Heal = 1,
  Bullet = 2,
  Explosive = 4,
  Fire = 8,
  Electric = 16,
}

public partial class HealthPool : Node
{
  [Godot.Export]
  required public float MaxHealth;

  internal DF.Lib.Timer.D _timer = () => DF.Model.Timer.Server.S();

  private bool _is_alive = true;

  internal DF.Lib.Tween.Float.Linear<bool?> _health = new()
  {
    WatchPoints = new Dictionary<float, DF.Lib.Tween.Float.EdgeType>
    {
      { 0, DF.Lib.Tween.Float.EdgeType.FallingEdge }
    }
  };

  private void _OnDeathHandler(object sender, DF.Lib.Tween.Float.ValueTriggerEventHandlerArgs<bool?> e)
  {
    if (e.V == 0 && e.EdgeType == DF.Lib.Tween.Float.EdgeType.FallingEdge)
    {
      Godot.GD.Print($"DEBUG(HealthPool.cs): at t ~ {(ulong)Math.Round((float)e.F.T / 1000)}s, HP has triggered {e.V}.");
      this._is_alive = false;
    }
  }

  public bool IsAlive() => this._is_alive;

  public override void _Notification(int what)
  {
    base._Notification(what);

    if (what == Godot.GodotObject.NotificationPredelete)
    {
      DF.Model.Tween.Directory.S().Remove(this._health.ID());
    }
  }

  public override void _Ready()
  {
    base._Ready();

    DF.Model.Tween.Directory.S().Add(this._health);

    this._health.WatchPoints[this.MaxHealth] = DF.Lib.Tween.Float.EdgeType.RisingEdge;
    this._health.Add([
      new(this._timer().CurrTick(), this.MaxHealth, null)]);

    this._health.ValueTriggerEvent += this._OnDeathHandler;
  }

  public void Damage(float v, DamageAttribute d)
  {
    float health = this.Health();
    if (health == 0)
    {
      return;
    }
    this._health.Merge(
      this._timer().CurrTick(),
      [
        new(
          this._timer().CurrTick() + 1,
          health + (d.HasFlag(DamageAttribute.Heal) ? 1 : -1) * v,
          false),
      ]);
  }

  public float Health()
  {
    DF.Lib.Tween.Frame<float, bool?>? f = this._health.Get(this._timer().CurrTick());
    if (!f.HasValue)
    {
      return 0;
    }
    return Godot.Mathf.Clamp(f.Value.V, 0, this.MaxHealth);
  }
}