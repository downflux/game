using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Runtime.CompilerServices;

namespace DF.Lib.Event;

/// <summary>
/// Event handler object which holds only a weak reference to handlers. This
/// allows callers to add a handler and be subsequently garbage collected
/// without causing memory leaks.
/// 
/// This is useful as curves are generally long-lived objects, but commands
/// which alter these curves are not.
/// </summary>
/// <remarks>
/// See <see cref="DF.Lib.Tween.Float.Linear{W}._value_trigger_event"/> for
/// example usage.
/// 
/// See <see href="https://www.meziantou.net/weak-events-in-csharp.htm" /> for
/// a more thorough explanation.
/// </remarks>
/// <typeparam name="T"></typeparam>
internal sealed class WeakEventHandler<T>
{
  private ImmutableList<WeakReference<EventHandler<T>>> _listeners = [];

  // Keep the delegates alive with their target. This prevent anonymous
  // delegates from being garbage collected prematurely.
  private readonly ConditionalWeakTable<object, List<object>> _keep_alive = [];

  public void Add(EventHandler<T> handler)
  {
    if (handler == null)
    {
      return;
    }

    var weak = new WeakReference<EventHandler<T>>(handler);
    _listeners = _listeners.Add(weak);
    if (handler.Target != null)
    {
      _keep_alive.GetOrCreateValue(handler.Target).Add(handler);
    }
  }

  public void Remove(EventHandler<T> handler)
  {
    if (handler == null)
    {
      return;
    }

    // Remove the handler and all handlers that have been garbage collected
    _listeners = _listeners.RemoveAll(wr => !wr.TryGetTarget(out var target) || handler.Equals(target));
    if (handler.Target != null && _keep_alive.TryGetValue(handler.Target, out var weak))
    {
      weak.Remove(handler);
    }
  }

  public void Invoke(object? sender, T args)
  {
    foreach (var listener in _listeners)
    {
      if (listener.TryGetTarget(out var handler))
      {
        handler.Invoke(sender, args);
      }
      else
      {
        // Remove the listener if the target has been garbage collected
        _listeners = _listeners.Remove(listener);
      }
    }
  }
}