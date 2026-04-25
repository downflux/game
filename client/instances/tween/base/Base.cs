using System;
using System.Collections.Generic;
using DF.Instances.Timer;
using Godot;

namespace DF.Instances.Tween;

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
public partial class Base<U, W> : Godot.Node
	where U : struct
{
	public string ID { get; }

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
		this.ID = System.Guid.NewGuid().ToString("D");
	}

	/// <remarks>
	/// Supposing <c>_Process()</c> is executed at <c>t1 > t0</c> the time at
	/// which the last time <c>_Process()</c> was called, control which events
	/// are emitted in the half-open interval <c>(t0, t1]</c> --
	///
	/// <list type="number">
	///   <item>
	///     <description>
	///       The default <see cref="Tween{U}.KeyFrameTriggerEvent" /> in the
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
}
