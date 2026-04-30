using System;

namespace DF.Lib.Timer;

public delegate ITimer D();

/// <summary>
/// Interface used to synchronize engine ticks.
/// </summary>
/// <remarks>
/// <see cref="DF.Lib.Tween.Base{U, W}"/> instances frequently require the use
/// of <c>ulong t</c> timestamps (with units of milliseconds) to look up
/// interpolated values. In order to be consistent across multiple instances,
/// the <see cref="ITimer"/> object is a singleton which is globally set.
/// 
/// For testing, objects which has an <see cref="ITimer"/> property may be
/// directly replaced with <see cref="Mock"/>, which manually sets the current
/// and previous ticks.    
/// </remarks>
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