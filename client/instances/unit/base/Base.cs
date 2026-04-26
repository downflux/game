using DF.Instances.Tween;
using Godot;
using System;
using System.Collections.Generic;

using F = DF.Lib.Tween.Frame<float, bool>;

public partial class Base : Node2D
{
  [Godot.Export]
  required public float MaxHP;

  private DF.Instances.Tween.HP hp() => this.GetNode<DF.Instances.Tween.HP>("HP");

  public override void _Ready()
  {
    base._Ready();

    this.hp().WatchPoints[this.MaxHP] = DF.Lib.Tween.EdgeType.RisingEdge;
  }

  public float HP()
  {
    var hp = this.hp().Get(DF.Instances.Timer.T.S().CurrTick());
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
      new(DF.Instances.Timer.T.S().CurrTick() + dt, v, false),
    ]);
  }

  public override void _Process(double dt)
  {
    base._Process(dt);

    this.GetNode<Godot.ProgressBar>("HPBar").Value = this.HP() / this.MaxHP * 100;
  }
}
