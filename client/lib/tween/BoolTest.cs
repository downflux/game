using GdUnit4;
using static GdUnit4.Assertions;
using System.Collections.Generic;

namespace DF.Tests.Lib.Tween;

[TestSuite]
public class BoolTest
{
  private DF.Lib.Tween.Bool<bool?> _t;
  [BeforeTest]
  public void SetUp()
  {
    this._t = new DF.Lib.Tween.Bool<bool?>(
      DF.Lib.Tween.InterpolationType.Pulse);
    this._t.Add(
      [
        new(10, true, true),
        new(20, true, null),
        new(30, true, null),
      ]);
    this._t.Flush();
  }

  [TestCase((ulong)10, true, true, true)]
  [TestCase((ulong)15, false, null, false)]
  [TestCase((ulong)25, false, null, false)]
  public void TestGet(ulong t, bool v, bool? d, bool k)
  {
    AssertThat(this._t.Get(t)).IsEqual(
      new DF.Lib.Tween.Frame<bool, bool?>(t, v, d, k));
  }

  [TestCase]
  public void TestSlice()
  {
    AssertThat(this._t.Slice(0, 10)).IsEqual(
      new List<DF.Lib.Tween.Frame<bool, bool?>>{
        new(10, true, true)});
    AssertThat(this._t.Slice(10, 10)).IsEqual(
      new List<DF.Lib.Tween.Frame<bool, bool?>>{
        new(10, true, true)});
    AssertThat(this._t.Slice(0, 11)).IsEqual(
      new List<DF.Lib.Tween.Frame<bool, bool?>>{
        new(10, true, true)});
    AssertThat(this._t.Slice(10, 20)).IsEqual(
      new List<DF.Lib.Tween.Frame<bool, bool?>>{
        new(10, true, true),
        new(20, true, null)});
    AssertThat(this._t.Slice(40, 50)).IsEqual(
      new List<DF.Lib.Tween.Frame<bool, bool?>>{
        new(40, false, null, false),
        new(50, false, null, false)});
  }
}