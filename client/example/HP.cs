using Godot;
using System;

public partial class HP : DF.Instances.Tween.Float<bool>
{
	public override void _Ready()
	{
		this._tween.Add([
			new (0, 100, false),
			new (10000, 0, false),
		]);
		this._tween.Flush();
		this.ValueTriggerEvent += (t, e) =>
			{
				GD.Print(
					$"DEBUG(Example.cs): at t ~ {(ulong)Math.Round((float)e.F.T / 1000)}s, HP has reached {e.F.V}.");
			};
	}
}
