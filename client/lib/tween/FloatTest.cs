using GdUnit4;
using static GdUnit4.Assertions;
using System.Collections.Generic;

namespace DF.Tests.Lib.Tween;

#pragma warning disable CS8618

[TestSuite]
public class FloatTest
{
	private DF.Lib.Tween.Float<bool?> _t;

	[BeforeTest]
	public void SetUp()
	{
		this._t = new DF.Lib.Tween.Float<bool?>(
			DF.Lib.Tween.InterpolationType.Linear);
		this._t.Add(
			[
				new(10, 110, true),
				new(20, 120, null),
				new(30, 130, null),
				new(40, 120, null),
				new(50, 130, null),
			]);
		this._t.Flush();
	}

	[TestCase]
	public void TestIntercept()
	{
		AssertThat(  // lb > ub
			this._t.Intercept(
				new(10, 110, true),
				new(0, 0, true),
				0,
				DF.Lib.Tween.EdgeType.FallingEdge)).IsNull();
		AssertThat(  // lb == null
			this._t.Intercept(
				null,
				new(10, 110, true),
				0,
				DF.Lib.Tween.EdgeType.FallingEdge)).IsNull();
		AssertThat(  // ub == null
			this._t.Intercept(
				new(10, 110, true),
				null,
				0,
				DF.Lib.Tween.EdgeType.FallingEdge)).IsNull();
		AssertThat(  // FallingEdge
			this._t.Intercept(
				new(10, 110, true),
				new(20, 120, true),
				115,
				DF.Lib.Tween.EdgeType.FallingEdge)).IsNull();
		AssertThat(  // RisingEdge
			this._t.Intercept(
				new(10, 120, true),
				new(20, 110, true),
				115,
				DF.Lib.Tween.EdgeType.RisingEdge)).IsNull();
		AssertThat(  // OOB
			this._t.Intercept(
				new(10, 110, true),
				new(20, 120, true),
				130,
				DF.Lib.Tween.EdgeType.RisingEdge)).IsNull();

		AssertThat(  // RisingEdge
			this._t.Intercept(
				new(10, 110, true),
				new(20, 120, true),
				115,
				DF.Lib.Tween.EdgeType.RisingEdge)).IsEqual(
			new DF.Lib.Tween.Frame<float, bool?>(15, 115, null, false));
		AssertThat(  // FallingEdge
			this._t.Intercept(
				new(10, 120, true),
				new(20, 110, true),
				115,
				DF.Lib.Tween.EdgeType.FallingEdge)).IsEqual(
			new DF.Lib.Tween.Frame<float, bool?>(15, 115, null, false));
		AssertThat(  // keyframe
			this._t.Intercept(
				new(10, 110, true),
				new(30, 130, true),
				120,
				DF.Lib.Tween.EdgeType.RisingEdge)).IsEqual(
			new DF.Lib.Tween.Frame<float, bool?>(20, 120, null, true));

		AssertThat(  // OOB
			this._t.Intercept(
				new(100, (float)80, true),
				new(200, (float)60, true),
				40,
				DF.Lib.Tween.EdgeType.FallingEdge)).IsNull();

		AssertThat(  // t = lb, for the half-open interval (lb, ub]
			this._t.Intercept(
				new(10, 110, true),
				new(20, 120, null),
				110,
				DF.Lib.Tween.EdgeType.RisingEdge)).IsNull();
		AssertThat(  // t = ub, for the half-open interval (lb, ub]
			this._t.Intercept(
				new(10, 110, true),
				new(20, 120, true),
				120,
				DF.Lib.Tween.EdgeType.RisingEdge)).IsEqual(
			new DF.Lib.Tween.Frame<float, bool?>(20, 120, null, true));
		AssertThat(  // lb.V < v < ub.V and Ceil
			this._t.Intercept(
				new(10, 110, true),
				new(11, 111, null, false),
				110.1f,
				DF.Lib.Tween.EdgeType.RisingEdge)).IsEqual(
			new DF.Lib.Tween.Frame<float, bool?>(11, 111, null, false));
	}

	[TestCase]
	public void TestFind()
	{
		AssertThat(  // OOB
			this._t.Find(null, null, 100, DF.Lib.Tween.EdgeType.RisingEdge)).IsEmpty();
		AssertThat(  // OOB
			this._t.Find(null, 9, 100, DF.Lib.Tween.EdgeType.RisingEdge)).IsEmpty();
		AssertThat(  // OOB
			this._t.Find(51, null, 100, DF.Lib.Tween.EdgeType.RisingEdge)).IsEmpty();

		AssertThat(
			this._t.Find(10, 15, 111, DF.Lib.Tween.EdgeType.FallingEdge)).IsEmpty();
		AssertThat(
			this._t.Find(10, 15, 111, DF.Lib.Tween.EdgeType.RisingEdge)).IsEqual(
				new List<DF.Lib.Tween.Frame<float, bool?>> {
					new (11, 111, null, false)
				});
		AssertThat(  // Multiple intercepts.
			this._t.Find(20, 50, 121, DF.Lib.Tween.EdgeType.RisingEdge)).IsEqual(
				new List<DF.Lib.Tween.Frame<float, bool?>> {
					new (21, 121, null, false),
					new (41, 121, null, false)
				});


		AssertThat(
			this._t.Find(30, 40, 129, DF.Lib.Tween.EdgeType.RisingEdge)).IsEmpty();
		AssertThat(
			this._t.Find(30, 40, 129, DF.Lib.Tween.EdgeType.FallingEdge)).IsEqual(
				new List<DF.Lib.Tween.Frame<float, bool?>> {
					new (31, 129, null, false)
				});
	}
}
