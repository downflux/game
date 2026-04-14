using Godot;
using System;
using System.Collections.Generic;

public class ValueTriggerListFactory<T> where T : struct {
/**
	public static SortedList<T, List<TriggerEvent<T>>> CreateValueTriggerList(
		Dictionary<T, TriggerEvent<T>> triggers,
		IComparer<T> cmp) => new SortedList<T, List<TriggerEvent<T>>>(triggers, cmp);
 */
}

[Signal]
public delegate void TriggerEvent<T>(string curve_id, ulong timestamp, T v) where T : struct;

public partial class CurveNode<T> : Node where T : struct {
	private DF.Lib.Curve<T> curve = new();
	
	private string id = "";
	private SortedList<ulong, List<TriggerEvent<T>>> schedule_triggers = new();
	private SortedList<T, List<TriggerEvent<T>>> value_triggers = new();
	
	public override void _Ready() {
	}
	
	public override void _Process(double delta) {
		this.curve.Flush();
	}
	
	public void Trim(ulong t) => this.curve.Trim(t);
	
	public void Merge(ulong? t, List<DF.Lib.Snapshot<T>> data) => this.curve.Merge(t, data);
	
	public void Schedule(ulong t, T? v) {
	}
	
	public DF.Lib.Snapshot<T>? Get(ulong t) => this.curve.Get(t);
	
	public List<DF.Lib.Snapshot<T>>? GetSlice((ulong? Lo, ulong? Hi) interval) => this.curve.GetSlice(interval);
	
	public void Clear() => this.curve.Clear();
}
