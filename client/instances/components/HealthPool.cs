using System;
using System.Collections.Generic;
using DF.Instances.Timer;
using Godot;

namespace DF.Instances.Components;

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

  internal DF.Lib.Timer.D _timer = () => DF.Instances.Timer.T.S();

  internal DF.Instances.Tween.Float.Linear<bool> _health = new()
  {
    WatchPoints = new Godot.Collections.Dictionary<float, DF.Lib.Tween.EdgeType> {
      { 0, DF.Lib.Tween.EdgeType.RisingEdge },
    },
  };

  public HealthPool()
  {
    this._health.WatchPoints[this.MaxHealth] = DF.Lib.Tween.EdgeType.RisingEdge;
  }

  public override void _Ready()
  {
    base._Ready();

    this._health.Add([new(this._timer().CurrTick(), this.MaxHealth, false)]);
    this._health.Init();

    this._health.ValueTriggerEvent += (t, e) =>
    {
      GD.Print(
        $"DEBUG(HealthPool.cs): at t ~ {(ulong)Math.Round((float)e.F.T / 1000)}s, HP has reached {e.F.V}.");
    };

    this.AddChild(this._health);
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
    DF.Lib.Tween.Frame<float, bool>? f = this._health.Get(this._timer().CurrTick());
    if (!f.HasValue)
    {
      return 0;
    }
    return Godot.Mathf.Clamp(f.Value.V, 0, this.MaxHealth);
  }
}