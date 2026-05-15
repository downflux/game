using Godot;
using Microsoft.VisualStudio.TestPlatform.TestExecutor;
using System;

public partial class Example : Node2D
{
	public override void _Ready()
	{
		var unit = this.GetNode<DF.Instances.Unit.Base>("Unit");
		var position = this.GetNode<DF.Instances.Tween.Position>("Unit/Position");

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

	public override void _UnhandledInput(InputEvent @event)
	{
		base._UnhandledInput(@event);

		if (@event is Godot.InputEventMouseButton eventMouse)
		{
			if (eventMouse.ButtonIndex.HasFlag(MouseButton.Left) && eventMouse.IsReleased())
			{
				// TODO(minkezhang): Break out HP into separate health object, with DoT.
				// TODO(minkezhang): Break out Position into own object, with path and velocity.
				// TODO(minkezhang): Break out server vs client rendering -- i.e. triggers.
				// TODO(minkezhang): Break out Weapon() object for AoE vs single target API.
				this.unit().Fire();  // TODO(minkezhang): Add target, vs. AoE.
			}
		}
	}

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
