using GdUnit4;
using static GdUnit4.Assertions;
using System.Collections.Generic;
using Mono.Cecil;
using System;

namespace DF.Tests.Lib.Path;

using F = (float T, DF.Lib.Position.Position? P);

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
      new(0, 1, 1),
      new(0, 2, 2),
      new(0, 3, 3),
    ]);
  }

  [TestCase]
  public void TestNext()
  {
    AssertThat(this._path.Next()).IsEqual(new Godot.Vector3I(0, 1, 1));

    this._path.SetNext();

    AssertThat(this._path.Next()).IsEqual(new Godot.Vector3I(0, 2, 2));

    this._path.SetNext();

    AssertThat(this._path.Next()).IsEqual(new Godot.Vector3I(0, 3, 3));

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
      new(0, 1, 1),
      new(1, 0, 1),
      new(2, 0, 2),
    });
  }

  [TestCase]
  public void TestMergeOverlap()
  {
    this._path.SetNext();

    this._path.Merge([
      new(0, 2, 2),
      new(2, 0, 2),
    ]);
    AssertThat(this._path.P()).IsEqual(new List<Godot.Vector3I>
    {
      new(0, 2, 2),
      new(2, 0, 2),
    });
  }

  [TestCase]
  public void TestGenerateRotationFrame()
  {
    AssertThat(  // No-op
      DF.Lib.Path.Path.GenerateRotationFrame(
        new(new(0, 0, 0), 0),
        new(new(0, 0, 0), 0),
        0,
        1
      )).IsEqual(
        new F(0, null));

    AssertThat(  // Instantaneous rotate
      DF.Lib.Path.Path.GenerateRotationFrame(
        new(new(0, 0, 0), 0),
        new(new(0, 1, 0), 1),
        0,
        0
      )).IsEqual(
        new F(1, new(new(0, 0, 0), 1)));

    AssertThat(  // Simple
      DF.Lib.Path.Path.GenerateRotationFrame(
        new(new(0, 0, 0), 0),
        new(new(0, 1, 0), (float)(Math.PI / 4)),
        0,
        (float)(Math.PI / 4)
      )).IsEqual(
        new F(1, new(new(0, 0, 0), (float)(Math.PI / 4))));

    AssertThat(  // Negative rotation
      DF.Lib.Path.Path.GenerateRotationFrame(
        new(new(0, 0, 0), 0),
        new(new(0, 1, 0), -(float)(Math.PI / 4)),
        0,
        (float)Math.PI / 4
      )).IsEqual(
        new F(1, new(new(0, 0, 0), -(float)(Math.PI / 4))));

    AssertThat(  // Negative rotation - overrotate
      DF.Lib.Path.Path.GenerateRotationFrame(
        new(new(0, 0, 0), 0),
        new(new(0, 1, 0), (float)(3 * Math.PI / 4)),
        0,
        (float)Math.PI / 4
      )).IsEqual(
        new F(3, new(new(0, 0, 0), (float)(3 * Math.PI / 4))));
  }

  [TestCase]
  public void TestGenerateTranslationFrame()
  {
    AssertThat(  // No-op
      DF.Lib.Path.Path.GenerateTranslationFrame(
        new(new(0, 0, 0), 0),
        new(new(0, 0, 0), 0),
        0,
        1
      )).IsEqual(
        new F(0, null));

    AssertThat(  // Simple
      DF.Lib.Path.Path.GenerateTranslationFrame(
        new(new(0, 0, 0), 0),
        new(new(0, 1, 0), 0),
        0,
        1
      )).IsEqual(
        new F(1, new(new(0, 1, 0), 0)));

    AssertThat(  // Preserve q.T
      DF.Lib.Path.Path.GenerateTranslationFrame(
        new(new(0, 0, 0), 0),
        new(new(0, 1, 0), (float)Math.PI),
        0,
        1
      )).IsEqual(
        new F(1, new(new(0, 1, 0), (float)Math.PI)));
  }

  [TestCase]
  public void TestFrames()
  {
    DF.Lib.Position.Position p = new(
      new(0, 0, 0.5f), 0);
    ulong t = 1;
    DF.Lib.Position.Velocity v = new(0.1f, 0, 0);

    AssertThat(this._path.Frames(p, t, v)).IsEqual(  // With no rotation
      new List<DF.Lib.Tween.Frame<DF.Lib.Position.Position, DF.Lib.Path.KeyFrameType>>
      {
        new(1, new(new(0, 0, 0.5f), 0), DF.Lib.Path.KeyFrameType.None),
        new(2, new(new(0, 0, 0.5f), (float)Math.PI / 2), DF.Lib.Path.KeyFrameType.CompletedTurn),
        new(12, new(new(0, 1, 1), (float)Math.PI / 2), DF.Lib.Path.KeyFrameType.ReachedTile),
        new(22, new(new(0, 2, 2), (float)Math.PI / 2), DF.Lib.Path.KeyFrameType.ReachedTile),
        new(
          32, new(new(0, 3, 3), (float)Math.PI / 2),
          DF.Lib.Path.KeyFrameType.ReachedTile | DF.Lib.Path.KeyFrameType.ReachedGoal),
      });

    AssertThat(this._path.Frames(p, t, new(0.1f, 0, (float)(Math.PI / 2)))).IsEqual(  // With rotation
      new List<DF.Lib.Tween.Frame<DF.Lib.Position.Position, DF.Lib.Path.KeyFrameType>>
      {
        new(1, new(new(0, 0, 0.5f), 0), DF.Lib.Path.KeyFrameType.None),
        new(2, new(new(0, 0, 0.5f), (float)(Math.PI / 2)), DF.Lib.Path.KeyFrameType.CompletedTurn),
        new(12, new(new(0, 1, 1), (float)(Math.PI / 2)), DF.Lib.Path.KeyFrameType.ReachedTile),
        new(22, new(new(0, 2, 2), (float)(Math.PI / 2)), DF.Lib.Path.KeyFrameType.ReachedTile),
        new(
          32, new(new(0, 3, 3), (float)(Math.PI / 2)),
          DF.Lib.Path.KeyFrameType.ReachedTile | DF.Lib.Path.KeyFrameType.ReachedGoal),
      });

  }
}