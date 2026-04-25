using System;

namespace DF.Lib.Timer;

public interface ITimer
{
  public ulong PrevTick();
  public ulong CurrTick();
}

public class Mock : ITimer
{

  private static readonly Lazy<Mock> _singleton = new(() => new Mock());

  public static Mock S() => _singleton.Value;

  internal ulong _prev_tick = 0;
  internal ulong _curr_tick = 0;

  public ulong PrevTick() => this._prev_tick;
  public ulong CurrTick() => this._curr_tick;

  public void SetPrevTick(ulong t) => this._prev_tick = t;
  public void SetCurrTick(ulong t) => this._curr_tick = t;
}