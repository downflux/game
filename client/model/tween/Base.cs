using System;
using System.Collections.Generic;

namespace DF.Model.Tween;

/// <summary>
/// <see cref="DF.Lib.Tween.ITween{U, W}"/> implementation to be referenced by Godot nodes.
/// </summary>
/// <remarks>
/// All mutate methods are written to an internal buffer and updated during <see cref="Godot.Node._Process(double)" />.
/// </remarks>
public interface ITween<U, W> : ITweenRO<U, W> where U : struct
{
	public string ID();

	/// <summary>
	/// Add a series of keyframes If <paramref name="init" /> is set to
	/// <c>true</c>, explicitly flushes the cache.
	/// </summary>
	/// <remarks>
	/// <c>_Ready()</c> is called in post-traversal order, but <c>_Process()</c>
	/// is called in pre-traversal order --
	/// 
	/// <list type="number"> 
	///   <item><c>child._Ready()</c></item>
	///   <item><c>parent._Ready()</c></item>
	///   <item><c>parent._Process()</c></item>
	///   <item><c>child._Process()</c></item>
	/// </list>
	/// 
	/// Therefore, calling with <paramref name="init" /> set will ensure that a
	/// defined value for each curve exists before the next <c>_Process()</c>
	/// cycle.
	/// 
	/// Do not set <paramref name="init"> outside of a parent's <c>_Ready()</c>
	/// function.
	/// </remarks>
	public void Add(List<DF.Lib.Tween.Frame<U, W>> fs);
	public void Remove(List<DF.Lib.Tween.Frame<U, W>> fs);
	public void Cut(ulong t);
	public void Merge(ulong t, List<DF.Lib.Tween.Frame<U, W>> fs);
	public void Scale(ulong? t, float r);
	public void Clear();
}

public interface ITweenRO<U, W> where U : struct
{
	public DF.Lib.Tween.Frame<U, W>? Get(ulong t);
	public List<DF.Lib.Tween.Frame<U, W>> Slice(ulong? lo, ulong? hi);
	public DF.Lib.Tween.InterpolationType Type();
}

public delegate void KeyframeTriggerEventHandler<U, W>(
	object sender,
	KeyframeTriggerEventHandlerArgs<U, W> e)
where U : struct;

public class KeyframeTriggerEventHandlerArgs<U, W>(DF.Lib.Tween.Frame<U, W> f) : EventArgs
	where U : struct
{
	public DF.Lib.Tween.Frame<U, W> F { get; } = f;
}

/// <summary>
/// Logic encapsulating the <see cref="DF.Lib.Tween.Base{U, W}" /> object within a
/// <see cref="Godot.Node" /> object.
/// </summary>
public partial class Base<U, W>(DF.Lib.Tween.ITween<U, W> t) : Godot.Node, ITween<U, W>
	where U : struct
{
	private string _id = System.Guid.NewGuid().ToString("D");

	/// <summary>
	/// Emitted whenever a keyframe occurs.
	/// </summary>
	public event KeyframeTriggerEventHandler<U, W>? KeyFrameTriggerEvent;

	/// <summary>
	/// Internal data model for this node, comprised of a list of
	/// { timestamp : data } tuples.
	/// </summary>
	internal DF.Lib.Tween.ITween<U, W> _tween = t;
	internal DF.Lib.Timer.D _timer = () => DF.Model.Timer.Server.S();

	/// <summary>
	/// Call this in parent <see cref="Godot.Node._Ready"/> calls; <c>_Ready</c>
	/// is in post-order traversal, but <see cref="Godot.Node._Process"/>
	/// is in pre-order traversal, meaning that child nodes
	/// (<see cref="Base{U, W}"/> instances) do not have an opportunity to update
	/// their internal cache before starting a tick.
	/// </summary>
	public void Init() => this._tween.Flush();

	/// <remarks>
	/// Supposing <c>_Process()</c> is executed at <c>t1 > t0</c> the time at
	/// which the last time <c>_Process()</c> was called, control which events
	/// are emitted in the half-open interval <c>(t0, t1]</c> --
	///
	/// <list type="number">
	///   <item>
	///     <description>
	///       The default <see cref="Base{U, W}.KeyFrameTriggerEvent" /> in the
	///       interval
	///     </description>
	///   </item>
	///   <item>
	///     <description>
	///       Any events stored in the frame data.
	///     </description>
	///   </item>
	///   <item>
	///     <description>
	///       Any events triggered by crossing a specific value.
	///     </description>
	///   </item>
	/// </list>
	/// </remarks>
	public override void _Process(double dt)
	{
		base._Process(dt);

		this._tween.Flush();

		List<DF.Lib.Tween.Frame<U, W>> slice = this._tween.Slice(this._timer().PrevTick(), this._timer().CurrTick());

		foreach (var f in slice)
		{
			// Ensure that we are not emitting a signal twice if the frame sits on
			// the boundary of the interval.
			if (f.IsKeyFrame() && f.T < this._timer().CurrTick())
			{
				// Emit the default keyframe trigger event.
				this.KeyFrameTriggerEvent?.Invoke(this, new KeyframeTriggerEventHandlerArgs<U, W>(f));
			}
		}
	}

	public string ID() => this._id;

	public void Add(List<DF.Lib.Tween.Frame<U, W>> fs) => this._tween.Add(fs);
	public void Remove(List<DF.Lib.Tween.Frame<U, W>> fs) => this._tween.Remove(fs);
	public DF.Lib.Tween.Frame<U, W>? Get(ulong t) => this._tween.Get(t);
	public List<DF.Lib.Tween.Frame<U, W>> Slice(ulong? lo, ulong? hi) => this._tween.Slice(lo, hi);
	public void Cut(ulong t) => this._tween.Cut(t);
	public void Merge(ulong t, List<DF.Lib.Tween.Frame<U, W>> fs) => this._tween.Merge(t, fs);
	public void Clear() => this._tween.Clear();
	public void Scale(ulong? t, float r) => this._tween.Scale(t, r);
	public DF.Lib.Tween.InterpolationType Type() => this._tween.Type();
}
