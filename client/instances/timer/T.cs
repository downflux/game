using System;

namespace DF.Instances.Timer;

/// <summary>
/// Singleton used to control timing lookups in
/// <see cref="DF.Lib.Tween.Base{U, W}"/> types. 
/// </summary>
public partial class T : Godot.Node, DF.Lib.Timer.ITimer
{
  private static T? _singleton;

  public static T S() => T._singleton!;

  internal ulong _prev_tick = 0;
  internal ulong _curr_tick = 0;

  public ulong PrevTick() => this._prev_tick;
  public ulong CurrTick() => this._curr_tick;

  public override void _Ready()
  {
    base._Ready();

    T._singleton = this;
  }

  public override void _Process(double delta)
  {
    base._Process(delta);

    this._prev_tick = this._curr_tick;
    this._curr_tick = Godot.Time.GetTicksMsec();
  }
}