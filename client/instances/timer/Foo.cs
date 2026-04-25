using Godot;
using System;

namespace DF.Instances.Timer;

public partial class Foo : Godot.Node, DF.Lib.Timer.ITimer
{
  private static Foo? _singleton;

  public static Foo S() => Foo._singleton!;

  internal ulong _prev_tick = 0;
  internal ulong _curr_tick = 0;

  public ulong PrevTick() => this._prev_tick;
  public ulong CurrTick() => this._curr_tick;

  public Foo()
  {
  }

  public override void _Ready()
  {
    Foo._singleton = this;
  }

  public override void _Process(double delta)
  {
    base._Process(delta);

    this._prev_tick = this._curr_tick;
    this._curr_tick = Godot.Time.GetTicksMsec();
  }
}