using GdUnit4;
using static GdUnit4.Assertions;
using System.Collections.Generic;

namespace DF.Tests.Lib.Path;

#pragma warning disable CS8618

[TestSuite]
public class PathTest
{
  private DF.Lib.Path.Path _path;
  [BeforeTest]
  public void SetUp()
  {
    this._path = new();
    this._path.Merge([
      new(0, 0, 1),
      new(0, 0, 2),
      new(0, 0, 3),
    ]);
  }

  [TestCase]
  public void TestNext()
  {
    AssertThat(this._path.Next()).IsEqual(new Godot.Vector3I(0, 0, 1));

    this._path.SetNext();

    AssertThat(this._path.Next()).IsEqual(new Godot.Vector3I(0, 0, 2));

    this._path.SetNext();

    AssertThat(this._path.Next()).IsEqual(new Godot.Vector3I(0, 0, 3));

    this._path.SetNext();

    AssertThat(this._path.Next()).IsNull();

    this._path.SetNext();

    AssertThat(this._path.Next()).IsNull();
  }

  [TestCase]
  public void TestMergeDistinct()
  {
    this._path.Merge([
      new(1, 0, 1),
      new(2, 0, 2),
    ]);
    AssertThat(this._path.P()).IsEqual(new List<Godot.Vector3I>
    {
      new(0, 0, 1),
      new(1, 0, 1),
      new(2, 0, 2),
    });
  }

  [TestCase]
  public void TestMergeOverlap()
  {
    this._path.SetNext();

    this._path.Merge([
      new(0, 0, 2),
      new(2, 0, 2),
    ]);
    AssertThat(this._path.P()).IsEqual(new List<Godot.Vector3I>
    {
      new(0, 0, 2),
      new(2, 0, 2),
    });
  }

  [TestCase]
  public void TestFrames()
  {
    AssertThat(this._path.Frames(1, new(0, 0, (float)0.5), 10)).IsEqual(
      new List<DF.Lib.Tween.Frame<Godot.Vector3, DF.Lib.Path.KeyFrameType>>
      {
        new(1, new(0, 0, (float)0.5), DF.Lib.Path.KeyFrameType.None),
        new(6, new(0, 0, 1), DF.Lib.Path.KeyFrameType.ReachedTile),
        new(16, new(0, 0, 2), DF.Lib.Path.KeyFrameType.ReachedTile),
        new(26, new(0, 0, 3), DF.Lib.Path.KeyFrameType.ReachedTile | DF.Lib.Path.KeyFrameType.ReachedGoal),
      }
    );
  }
}