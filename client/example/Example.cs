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
			new(50, 350, 0),
			new(300, 200, 0),
			new(200, 350, 0),
			new(200, 400, 0),
			new(50, 350, 0),
			new(200, 350, 0),
		], true);
	}

	private DF.Instances.Unit.Base unit() => (DF.Instances.Unit.Base)this.GetNode("Unit");

	public override void _UnhandledKeyInput(InputEvent @event)
	{
		base._UnhandledKeyInput(@event);

		if (@event is Godot.InputEventKey eventKey)
		{
			if (eventKey.Pressed && eventKey.Keycode == Key.Up)
			{
				Godot.GD.Print("DEBUG(Example.cs): Increasing speed");
				DF.Lib.Position.Velocity v = this.unit().Velocity();
				this.unit().SetVelocity(new(v.XY + 1f * this.unit().BaseVelocity, v.Z, v.W + this.unit().BaseAngularVelocity));
			}
			if (eventKey.Pressed && eventKey.Keycode == Key.Down)
			{
				Godot.GD.Print("DEBUG(Example.cs): Decreasing speed");
				DF.Lib.Position.Velocity v = this.unit().Velocity();
				this.unit().SetVelocity(new(v.XY - 1f * this.unit().BaseVelocity, v.Z, v.W - this.unit().BaseAngularVelocity));
			}
		}
	}
}
