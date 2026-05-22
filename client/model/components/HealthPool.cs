using System;
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

  private bool _is_alive = true;

  internal DF.Instances.Tween.Float.Linear<bool?> _health = new()
  {
    WatchPoints = new Godot.Collections.Dictionary<float, DF.Lib.Tween.EdgeType> {
      { 0, DF.Lib.Tween.EdgeType.FallingEdge },
    },
  };

  private void _DeathHandler(object sender, DF.Instances.Tween.Float.ValueTriggerEventHandlerArgs<bool?> e)
  {
    if (e.V == 0 && e.EdgeType == DF.Lib.Tween.EdgeType.FallingEdge)
    {
      this._is_alive = false;
    }
  }

  public bool IsAlive() => this._is_alive;

  public override void _Ready()
  {
    base._Ready();

    this._health.WatchPoints[this.MaxHealth] = DF.Lib.Tween.EdgeType.RisingEdge;
    this._health.Add([
      new(this._timer().CurrTick(), this.MaxHealth, null)]);
    this._health.Init();

    this._health.ValueTriggerEvent += this._DeathHandler;
    this._health.ValueTriggerEvent += (t, e) =>
    {
      GD.Print(
        $"DEBUG(HealthPool.cs): at t ~ {(ulong)Math.Round((float)e.F.T / 1000)}s, HP has triggered {e.V}.");
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
    DF.Lib.Tween.Frame<float, bool?>? f = this._health.Get(this._timer().CurrTick());
    if (!f.HasValue)
    {
      return 0;
    }
    return Godot.Mathf.Clamp(f.Value.V, 0, this.MaxHealth);
  }
}