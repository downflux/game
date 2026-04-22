using GdUnit4;
using static GdUnit4.Assertions;

namespace DF.Tests.Tween;

[TestSuite]
public class FloatTest
{
	private DF.Lib.Tween.Float<bool?> _t = new DF.Lib.Tween.Float<bool?>(
		DF.Lib.Tween.InterpolationType.Linear);
	
	[BeforeTest]
	public void SetUp()
	{
		this._t = new  DF.Lib.Tween.Float<bool?>(
			DF.Lib.Tween.InterpolationType.Linear);
		this._t.Add(
			new System.Collections.Generic.List<DF.Lib.Tween.Frame<float, bool?>>{
				new(10, 110, true),
				new(20, 120, null),
				new(30, 130, null),
			});
		this._t.Flush();
	}
	
	[TestCase]
	public void TestIntercept()
	{
		AssertThat(  // lb > ub
			this._t.Intercept(
				new (10, 110, true),
				new (0, 0, true),
				0,
				DF.Lib.Tween.EdgeType.FallingEdge)).IsNull();
		AssertThat(  // lb == null
			this._t.Intercept(
				null,
				new (10, 110, true),
				0,
				DF.Lib.Tween.EdgeType.FallingEdge)).IsNull();
		AssertThat(  // ub == null
			this._t.Intercept(
				new (10, 110, true),
				null,
				0,
				DF.Lib.Tween.EdgeType.FallingEdge)).IsNull();
		AssertThat(  // FallingEdge
			this._t.Intercept(
				new (10, 110, true),
				new (20, 120, true),
				115,
				DF.Lib.Tween.EdgeType.FallingEdge)).IsNull();
		AssertThat(  // RisingEdge
			this._t.Intercept(
				new (10, 120, true),
				new (20, 110, true),
				115,
				DF.Lib.Tween.EdgeType.RisingEdge)).IsNull();
		AssertThat(  // OOB
			this._t.Intercept(
				new (10, 110, true),
				new (20, 120, true),
				130,
				DF.Lib.Tween.EdgeType.RisingEdge)).IsNull();
		
		AssertThat(  // RisingEdge
			this._t.Intercept(
				new (10, 110, true),
				new (20, 120, true),
				115,
				DF.Lib.Tween.EdgeType.RisingEdge)).IsEqual(
			new DF.Lib.Tween.Frame<float, bool?>(15, 115, null, false));
		AssertThat(  // FallingEdge
			this._t.Intercept(
				new (10, 120, true),
				new (20, 110, true),
				115,
				DF.Lib.Tween.EdgeType.FallingEdge)).IsEqual(
			new DF.Lib.Tween.Frame<float, bool?>(15, 115, null, false));
		AssertThat(  // keyframe
			this._t.Intercept(
				new (10, 110, true),
				new (30, 130, true),
				120,
				DF.Lib.Tween.EdgeType.RisingEdge)).IsEqual(
			new DF.Lib.Tween.Frame<float, bool?>(20, 120, null, true));
	}
}
