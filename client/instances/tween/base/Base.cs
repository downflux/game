using System;
using System.Collections.Generic;

namespace DF.Instances.Tween;

/// <summary>
/// <see cref="DF.Lib.Tween.ITween{U, W}"/> implementation to be referenced by Godot nodes.
/// </summary>
/// <remarks>
/// All mutate methods are written to an internal buffer and updated during <see cref="Godot.Node._Process(double)" />.
/// </remarks>
public interface ITween<U, W> where U : struct
{
	public string ID();

	public void Add(List<DF.Lib.Tween.Frame<U, W>> fs);
	public void Remove(List<DF.Lib.Tween.Frame<U, W>> fs);
	public DF.Lib.Tween.Frame<U, W>? Get(ulong t);
	public List<DF.Lib.Tween.Frame<U, W>> Slice(ulong? lo, ulong? hi);
	public void Cut(ulong t);
	public void Merge(ulong t, List<DF.Lib.Tween.Frame<U, W>> fs);
	public void Clear();
}

public delegate void TriggerEventHandler<U, W>(
	object sender,
	TriggerEventHandlerArgs<U, W> e)
where U : struct;

public class TriggerEventHandlerArgs<U, W> : EventArgs
	where U : struct
{
	public DF.Lib.Tween.Frame<U, W> F { get; }

	public TriggerEventHandlerArgs(DF.Lib.Tween.Frame<U, W> f) => this.F = f;
}

/// <summary>
/// Logic encapsulating the <see cref="DF.Lib.Tween.Base{U, W}" /> object within a
/// <see cref="Godot.Node" /> object.
/// </summary>
public partial class Base<U, W> : Godot.Node, ITween<U, W>
	where U : struct
{
	private string _id = "";

	/// <summary>
	/// Emitted whenever a keyframe occurs.
	/// </summary>
	public event TriggerEventHandler<U, W>? KeyFrameTriggerEvent;

	/// <summary>
	/// Internal data model for this node, comprised of a list of
	/// { timestamp : data } tuples.
	/// </summary>
	internal DF.Lib.Tween.ITween<U, W> _tween;
	internal DF.Lib.Timer.D _timer = () => DF.Instances.Timer.T.S();

	public Base(DF.Lib.Tween.ITween<U, W> tween)
	{
		this._tween = tween;
		this._id = System.Guid.NewGuid().ToString("D");
	}

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
			if (f.K)
			{
				// Emit the default keyframe trigger event.
				this.KeyFrameTriggerEvent?.Invoke(this, new TriggerEventHandlerArgs<U, W>(f));
			}
		}
	}

	public string ID() => this._id;
	public void Add(List<DF.Lib.Tween.Frame<U, W>> fs) => this._tween.Add(fs);
	public void Remove(List<DF.Lib.Tween.Frame<U, W>> fs) => this._tween.Remove(fs);
	public DF.Lib.Tween.Frame<U, W>? Get(ulong t) => this._tween.Get(t);
	public List<DF.Lib.Tween.Frame<U, W>> Slice(ulong? lo, ulong? hi) => this._tween.Slice(lo, hi);
	public void Cut(ulong t) => this._tween.Cut(t);
	public void Merge(ulong t, List<DF.Lib.Tween.Frame<U, W>> fs) => this.Merge(t, fs);
	public void Clear() => this._tween.Clear();
}
