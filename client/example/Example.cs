using Godot;
using Microsoft.VisualStudio.TestPlatform.TestExecutor;
using System;

public partial class Example : Node2D
{
	public override void _Ready()
	{
		var unit = this.GetNode<DF.Instances.Unit.Base>("Unit");
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

		unit.SetPath([
			new(100, 200, 0),
			new(200, 100, 0),
			new(100, 200, 0),
		]);
	}

	public override void _Process(double delta)
	{
	}
}
