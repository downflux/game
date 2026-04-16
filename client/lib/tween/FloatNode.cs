using System;
using System.Collections.Generic;

namespace DF.Lib.Tween;

public partial class FloatNode : TweenNode<float>
{
	[Godot.Export]
	required public Godot.Collections.Array<float> WatchPoints;
}

public delegate void FrameTriggerEventHandler<T>(object sender, FrameTriggerEventArgs<T> e) where T : struct;

public delegate bool ValueTriggerComparater<T>(T v) where T : struct;

public class FrameTriggerEventArgs<T> : EventArgs where T : struct
{
	public DF.Lib.Tween.Frame<T, FrameTriggerEventHandler<T>> F { get; }
	
	public FrameTriggerEventArgs(DF.Lib.Tween.Frame<T, FrameTriggerEventHandler<T>> f) => this.F = f;
}

/// <summary>
/// Logic encapsulating the <see cref="DF.Lib.Tween.Tween{T}" /> object within a
/// <see cref="Godot.Node" /> object.
/// </summary>
public partial class TweenNode<T> : Godot.Node where T : struct
{
	public string ID { get; }
	
	/// <summary>
	/// Emitted whenever a keyframe occurs.
	/// </summary>
	public event FrameTriggerEventHandler<T>? KeyFrameTriggerEvent;
	
	/// <summary>
	/// Interpolation model for this tween in between keyframes.
	/// </summary>
	[Godot.Export]
	required public DF.Lib.Tween.InterpolationType InterpolationType;
	
	protected List<ValueTriggerComparater<T>> _value_triggers = new();
	
	/// <summary>
	/// Internal data model for this node, comprised of a list of
	/// { timestamp : data } tuples.
	/// </summary>
	private DF.Lib.Tween.Tween<T, FrameTriggerEventHandler<T>> _tween;
	
	private ulong? _last_tick_ms = null;
	
	public TweenNode()
	{
		this._tween = new DF.Lib.Tween.Tween<T, FrameTriggerEventHandler<T>>(
			this.InterpolationType);
		this.ID = System.Guid.NewGuid().ToString("D");
	}
	
	public override void _Ready()
	{
	}
	
	/// <remarks>
	/// Supposing <c>_Process()</c> is executed at <c>t1 > t0</c> the time at
	/// which the last time <c>_Process()</c> was called, control which events
	/// are emitted in the half-open interval <c>(t0, t1]</c> --
	///
	/// <list type="number">
	///   <item>
	///     <description>
	///       The default <see cref="TweenNode{T}.KeyFrameTriggerEvent" /> in the
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
		(ulong? lo, ulong? hi) = (
			!this._last_tick_ms.HasValue ? null : this._last_tick_ms.Value + 1,
			Godot.Time.GetTicksMsec());
		
		List<DF.Lib.Tween.Frame<T, FrameTriggerEventHandler<T>>> slice = this._tween.Slice(lo, hi);
		
		foreach (var f in slice)
		{
			if (f.K) {
				// Emit the default keyframe trigger event.
				this.KeyFrameTriggerEvent?.Invoke(this, new FrameTriggerEventArgs<T>(f));
				
				// Emit user-defined custom events.
				f.D?.Invoke(this, new FrameTriggerEventArgs<T>(f));
			}
		}
		
		// The value at the end of the last interval. This is used to check if any
		// values have crossed a threshold between then and the first tick of the
		// current interval.
		DF.Lib.Tween.Frame<T, FrameTriggerEventHandler<T>>? pf = (
			!this._last_tick_ms.HasValue ? null : this._tween.Get(
				_last_tick_ms.Value));
		
		foreach (var t in this._value_triggers)
		{
			(bool? before, bool? after) = (null, null);
			
			for (var i = 0; i < slice.Count; i++)
			{
				var f = slice[i];
				
				if (i == 0) {
					before = (pf.HasValue) ? t?.Invoke(pf.Value.V) : null;
				}
				else
				{
					before = after;
				}
				
				after = t?.Invoke(f.V);
				
				// A threshold has been triggered.
				if (
					(
						before.HasValue && !before.Value) && (
						after.HasValue && after.Value))
				{
					f.D?.Invoke(this, new FrameTriggerEventArgs<T>(f));
				}
				
				before = after;
			}
		}
		
		// _Process() is in pre-order traversal. See
		// https://docs.godotengine.org/en/stable/tutorials/scripting/scene_tree.html#tree-order
		// for more information.
		this._tween.Flush();
	}
}
