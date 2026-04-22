/**
using GdUnit4;
using static GdUnit4.Assertions;

namespace DF.Tests.Float;

[TestSuite]
public class FloatNodeTest
{
	private DF.Lib.TweenNode.TweenNode<float> _t = new() { InterpolationType = DF.Lib.Tween.InterpolationType.Linear };
	
	[BeforeTest]
	public void SetUp()
	{
		this._t = new() { InterpolationType = DF.Lib.Tween.InterpolationType.Linear };
		this._t._tween.Add(
			new System.Collections.Generic.List<DF.Lib.Tween.Frame<float, DF.Lib.TweenNode.FrameTriggerEventHandler<float>>>{
				new(10, 110, null),
				new(20, 120, null),
				new(30, 130, null),
			});
		this._t._tween.Flush();
	}
	
	[TestCase]
	public void TestFindLinearFloat()
	{
		AssertThat(this._t.FindLinear(  // Impossible intersect.
			new DF.Lib.Tween.Frame<float, DF.Lib.TweenNode.FrameTriggerEventHandler<float>>(10, 110, null),
			new DF.Lib.Tween.Frame<float, DF.Lib.TweenNode.FrameTriggerEventHandler<float>>(10, 110, null),
			0)).IsNull();
		AssertThat(this._t.FindLinear(  // Intersect out of bounds.
			new DF.Lib.Tween.Frame<float, DF.Lib.TweenNode.FrameTriggerEventHandler<float>>(10, 110, null),
			new DF.Lib.Tween.Frame<float, DF.Lib.TweenNode.FrameTriggerEventHandler<float>>(10, 110, null),
			121)).IsNull();
		AssertThat(this._t.FindLinear(  // Singular point.
			new DF.Lib.Tween.Frame<float, DF.Lib.TweenNode.FrameTriggerEventHandler<float>>(10, 110, null),
			new DF.Lib.Tween.Frame<float, DF.Lib.TweenNode.FrameTriggerEventHandler<float>>(10, 110, null),
			110)).IsEqual(10);
		AssertThat(this._t.FindLinear(  // Horizontal line.
			new DF.Lib.Tween.Frame<float, DF.Lib.TweenNode.FrameTriggerEventHandler<float>>(10, 110, null),
			new DF.Lib.Tween.Frame<float, DF.Lib.TweenNode.FrameTriggerEventHandler<float>>(20, 110, null),
			110)).IsEqual(10);
		AssertThat(this._t.FindLinear(  // Simple.
			this._t._tween.Get(10) ?? throw new System.Exception("must be non-null"),
			this._t._tween.Get(20) ?? throw new System.Exception("must be non-null"),
			111)).IsEqual(11);
	}
}
 */
