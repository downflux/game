using GdUnit4;
using static GdUnit4.Assertions;

namespace DF.Tests.Lib.Tween;

[TestSuite]
public class BaseTest
{
	private DF.Lib.Tween.Base<float, bool?> _t = new DF.Lib.Tween.Base<float, bool?>(
		DF.Lib.Tween.InterpolationType.Linear);

	[BeforeTest]
	public void SetUp()
	{
		this._t = new DF.Lib.Tween.Base<float, bool?>(
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
	public void TestGetNull()
	{
		AssertThat(this._t.Get(0)).IsNull();
	}

	[TestCase((ulong)10, 110, true, true)]
	[TestCase((ulong)15, 115, null, false)]
	[TestCase((ulong)25, 125, null, false)]
	public void TestGet(ulong t, float v, bool? d, bool k)
	{
		AssertThat(this._t.Get(t)).IsEqual(
			new DF.Lib.Tween.Frame<float, bool?>(t, v, d, k));
	}

	[TestCase]
	public void TestLowerBoundNull()
	{
		AssertThat(this._t.LowerBound(0)).IsNull();
	}

	[TestCase((ulong)10, (ulong)10, 110, true)]
	[TestCase((ulong)15, (ulong)10, 110, true)]
	[TestCase((ulong)35, (ulong)30, 130, null)]
	public void TestLowerBound(ulong t, ulong u, float v, bool? d)
	{
		AssertThat(_t.LowerBound(t)).IsEqual(
			new DF.Lib.Tween.Frame<float, bool?>(u, v, d));
	}

	[TestCase]
	public void TestUpperBoundNull()
	{
		AssertThat(this._t.UpperBound(40)).IsNull();
	}

	[TestCase((ulong)0, (ulong)10, 110, true)]
	[TestCase((ulong)10, (ulong)10, 110, true)]
	[TestCase((ulong)15, (ulong)20, 120, null)]
	public void TestUpperBound(ulong t, ulong u, float v, bool? d)
	{
		AssertThat(_t.UpperBound(t)).IsEqual(
			new DF.Lib.Tween.Frame<float, bool?>(u, v, d));
	}

	[TestCase]
	public void TestSliceAll()
	{
		AssertThat(this._t.Slice(null, null)).IsEqual(
			new System.Collections.Generic.List<DF.Lib.Tween.Frame<float, bool?>>{
				new(10, 110, true),
				new(20, 120, null),
				new(30, 130, null)});
	}

	[TestCase]
	public void TestSliceEmpty()
	{
		AssertThat(this._t.Slice(null, 9)).IsEqual(
			new System.Collections.Generic.List<DF.Lib.Tween.Frame<float, bool?>>());
		AssertThat(this._t.Slice(31, null)).IsEqual(
			new System.Collections.Generic.List<DF.Lib.Tween.Frame<float, bool?>>());
	}

	[TestCase]
	public void TestSlice()
	{
		AssertThat(this._t.Slice(0, 10)).IsEqual(
			new System.Collections.Generic.List<DF.Lib.Tween.Frame<float, bool?>>{
				new(10, 110, true)});
		AssertThat(this._t.Slice(10, 10)).IsEqual(
			new System.Collections.Generic.List<DF.Lib.Tween.Frame<float, bool?>>{
				new(10, 110, true)});
		AssertThat(this._t.Slice(0, 11)).IsEqual(
			new System.Collections.Generic.List<DF.Lib.Tween.Frame<float, bool?>>{
				new(10, 110, true),
				new(11, 111, null, false)});
		AssertThat(this._t.Slice(10, 20)).IsEqual(
			new System.Collections.Generic.List<DF.Lib.Tween.Frame<float, bool?>>{
				new(10, 110, true),
				new(20, 120, null)});
	}

	[TestCase((ulong)0)]
	[TestCase((ulong)10)]
	public void TestCutAll(ulong t)
	{
		this._t.Cut(t);
		this._t.Flush();

		AssertThat(this._t.Slice(null, null)).IsEmpty();
	}

	public void TestCut()
	{
		this._t.Cut(11);
		this._t.Flush();

		AssertThat(this._t.Slice(null, null)).IsEqual(
			new System.Collections.Generic.List<DF.Lib.Tween.Frame<float, bool?>>{
				new(10, 110, true)});
	}

	[TestCase]
	public void TestMerge()
	{
		this._t.Merge(
			25,
			new System.Collections.Generic.List<DF.Lib.Tween.Frame<float, bool?>>{
				new(30, 140, null),
				new(40, 150, null),
			});
		this._t.Flush();

		AssertThat(this._t.Slice(null, null)).IsEqual(
			new System.Collections.Generic.List<DF.Lib.Tween.Frame<float, bool?>>{
				new(10, 110, true),
				new(20, 120, null),
				new(25, 125, null),
				new(30, 140, null),
				new(40, 150, null)});
	}
}
