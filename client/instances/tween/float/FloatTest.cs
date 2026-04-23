using GdUnit4;
using static GdUnit4.Assertions;

namespace DF.Tests.Instances.Tween;

[TestSuite]
[RequireGodotRuntime]
public class FloatNodeTest
{
	private DF.Instances.Tween.Float _n = new DF.Instances.Tween.Float() {
		WatchPoints = new Godot.Collections.Dictionary<float, DF.Lib.Tween.EdgeType>
		{
			{ 50, DF.Lib.Tween.EdgeType.RisingEdge },
		}
	};
	
	[BeforeTest]
	public void SetUp()
	{
		this._n = new DF.Instances.Tween.Float() {
			WatchPoints = new Godot.Collections.Dictionary<float, DF.Lib.Tween.EdgeType>
			{
				{ 50, DF.Lib.Tween.EdgeType.FallingEdge },
			}
		};
		
		this._n._tween.Add(
			new System.Collections.Generic.List<DF.Lib.Tween.Frame<float, DF.Instances.Tween.FrameTriggerEventHandler<float>>>{
				new(0, 100, null),
				new(100, 0, null),
			});
		this._n._tween.Flush();
	}
	
	[TestCase]
	public void TestTrigger()
	{
	}
}
