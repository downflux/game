using Godot;
using Microsoft.VisualStudio.TestPlatform.TestExecutor;
using System;

public partial class Example : Node2D
{
	public override void _Ready()
	{
		var hp = this.GetNode<DF.Instances.Tween.HP>("Unit/HP");
		var position = this.GetNode<DF.Instances.Tween.Position>("Unit/Position");

		hp.Add([
			new (0, 100, false),
			new (10000, 0, false),
		]);
		hp.ValueTriggerEvent += (t, e) =>
		{
			GD.Print(
				$"DEBUG(Example.cs): at t ~ {(ulong)Math.Round((float)e.F.T / 1000)}s, HP has reached {e.F.V}.");
		};

		position.Add([
			new (10000, new (100, 100, 0), DF.Lib.Path.KeyFrameType.ReachedGoal),
		]);
	}

	public override void _Process(double delta)
	{
	}
}
