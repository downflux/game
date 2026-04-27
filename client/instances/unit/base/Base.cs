using DF.Instances.Tween;
using Godot;
using System;
using System.Collections.Generic;

namespace DF.Instances.Unit;

using F = DF.Lib.Tween.Frame<float, bool>;

public partial class Base : Node2D
{
  [Godot.Export]
  required public float MaxHP;

  private DF.Instances.Tween.HP hp() => this.GetNode<DF.Instances.Tween.HP>("HP");
  private DF.Instances.Tween.Vector3 position() => this.GetNode<DF.Instances.Tween.Vector3>("Position");
  internal DF.Lib.Timer.D _timer = () => DF.Instances.Timer.T.S();

  public override void _Ready()
  {
    base._Ready();

    this.hp().Init(
      new(this._timer().CurrTick(), this.MaxHP, false));
    this.position().Init(
      new(this._timer().CurrTick(), new(this.Position.X, this.Position.Y, 0), false));

    this.hp().WatchPoints[this.MaxHP] = DF.Lib.Tween.EdgeType.RisingEdge;
  }

  /// <summary>
  /// Calculates the "true" 3D position of the isometric unit.
  /// </summary>
  public Godot.Vector3 Position3D() => this.position().Get(this._timer().CurrTick())!.Value.V;

  public float HP()
  {
    var hp = this.hp().Get(this._timer().CurrTick());
    if (hp.HasValue)
    {
      return Godot.Mathf.Clamp(hp.Value.V, 0, this.MaxHP);
    }
    return this.MaxHP;
  }

  public void SetHP(float v, ulong dt)
  {
    if (v > this.MaxHP || v < 0)
    {
      throw new ArgumentOutOfRangeException(
        nameof(v),
        $"setting HP {v} outside of valid range [{0}, {this.MaxHP}]");
    }

    this.hp().Add([
      new(this._timer().CurrTick() + dt, v, false),
    ]);
  }

  public override void _Process(double dt)
  {
    base._Process(dt);

    this.GetNode<Godot.ProgressBar>("HPBar").Value = this.HP() / this.MaxHP * 100;

    var p = this.Position3D();
    this.Position = new Godot.Vector2(p.X, p.Y);
  }
}
