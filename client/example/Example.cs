using Godot;
using System;

public partial class Example : Node2D
{
	public override void _Ready()
	{
		DF.Lib.Float.FloatNode hp = GetNode<DF.Lib.Float.FloatNode>("HPBar");
		hp._tween.Add(new System.Collections.Generic.List<DF.Lib.Tween.Frame<float, DF.Lib.TweenNode.FrameTriggerEventHandler<float>>>{
			new (0, 100, null),
			new (10000, 0, null)});
		hp._tween.Flush();
		hp.ValueTriggerEvent += (t, e) =>
			{
				GD.Print($"HP DIED: {e}");
			};
	}
	
	public override void _Process(double delta)
	{
		DF.Lib.Float.FloatNode hp = GetNode<DF.Lib.Float.FloatNode>("HPBar");
		DF.Lib.Tween.Frame<float, DF.Lib.TweenNode.FrameTriggerEventHandler<float>>? cur_hp = hp._tween.Get(Godot.Time.GetTicksMsec());
		if (cur_hp.HasValue)
		{
			// GD.Print($"{cur_hp.Value.V}");
		}
	}
}
