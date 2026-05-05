using GdUnit4;
using static GdUnit4.Assertions;

namespace DF.Tests.Instances.Tween;

[TestSuite]
[RequireGodotRuntime]
public class FloatTest
{
	private DF.Instances.Tween.Float.Linear<bool> _n = new DF.Instances.Tween.Float.Linear<bool>()
	{
		WatchPoints = new Godot.Collections.Dictionary<float, DF.Lib.Tween.EdgeType>
		{
			{ 50, DF.Lib.Tween.EdgeType.RisingEdge },
		}
	};

	[BeforeTest]
	public void SetUp()
	{
		this._n = new DF.Instances.Tween.Float.Linear<bool>()
		{
			WatchPoints = new Godot.Collections.Dictionary<float, DF.Lib.Tween.EdgeType>
			{
				{ 50, DF.Lib.Tween.EdgeType.FallingEdge },
			}
		};

		this._n._tween.Add(
			[
				new(0, 100, false),
				new(100, 0, false),
			]);
		this._n._tween.Flush();
	}
}
