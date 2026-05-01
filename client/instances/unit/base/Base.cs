using Godot;
using Microsoft.VisualStudio.TestPlatform.Utilities;
using System;
using System.Collections.Generic;

namespace DF.Instances.Unit;

public partial class Base : Node2D
{
  [Godot.Export]
  required public float MaxHP;

  private DF.Instances.Tween.HP hp() => this.GetNode<DF.Instances.Tween.HP>("HP");
  private DF.Instances.Tween.Position position() => this.GetNode<DF.Instances.Tween.Position>("Position");
  internal DF.Lib.Timer.D _timer = () => DF.Instances.Timer.T.S();
  internal DF.Lib.Path.Path _path = new();

  public override void _Ready()
  {
    base._Ready();

    this.hp().Add(
      [
        new(this._timer().CurrTick(), this.MaxHP, false),
      ], true);
    this.position().Add(
      [
        new(
          this._timer().CurrTick(),
          new(
            this.Position.X,
            this.Position.Y, 0),
            DF.Lib.Path.KeyFrameType.ReachedTile),
      ], true);

    this.hp().WatchPoints[this.MaxHP] = DF.Lib.Tween.EdgeType.RisingEdge;

    this.position().KeyFrameTriggerEvent += (t, e) =>
    {
      if (e.F.D.HasFlag(DF.Lib.Path.KeyFrameType.ReachedTile))
      {
        GD.Print(
            $"DEBUG(Example.cs): at t ~ {(ulong)Math.Round((float)e.F.T / 1000)}s, KeyFrame triggered at {e.F.V}.");
      }
    };
    this.position().KeyFrameTriggerEvent += this._path.KeyFrameTriggerEventHandler;
  }

  /// <summary>
  /// Calculates the "true" 3D position of the isometric unit.
  /// </summary>
  public Godot.Vector3 Position3D() => this.position().Get(this._timer().CurrTick())!.Value.V;

  public float HP() => Godot.Mathf.Clamp(this.hp().Get(this._timer().CurrTick())!.Value.V, 0, this.MaxHP);

  public void SetPath(List<Godot.Vector3I> p)
  {
    this._path.Merge(p);
    this.position().Merge(
      this._timer().CurrTick(),
      this._path.Frames(
        this._timer().CurrTick(),
        this.Position3D(),
        (float)0.05)); // TODO(minkezhang): Velocity curve.
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
