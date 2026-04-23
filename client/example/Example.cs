using Godot;
using System;

public partial class Example : Node2D
{
	public override void _Ready()
	{
		DF.Instances.Tween.Float hp = GetNode<DF.Instances.Tween.Float>("HPBar");
		hp._tween.Add(new System.Collections.Generic.List<DF.Lib.Tween.Frame<float, DF.Instances.Tween.FrameTriggerEventHandler<float>>>{
			new (0, 100, null),
			new (10000, 0, null)});
		hp._tween.Flush();
		hp.ValueTriggerEvent += (t, e) =>
			{
				GD.Print($"DEBUG(Example.cs): HP has reached 0.");
			};
	}
	
	public override void _Process(double delta)
	{
		DF.Instances.Tween.Float hp = GetNode<DF.Instances.Tween.Float>("HPBar");
		DF.Lib.Tween.Frame<float, DF.Instances.Tween.FrameTriggerEventHandler<float>>? cur_hp = hp._tween.Get(Godot.Time.GetTicksMsec());
	}
}
