using Godot;
using System;
using System.Collections.Generic;
using System.Numerics;

namespace DF.Instances.Debug;

public partial class Unit : Node2D
{
  [Godot.Export]
  DF.Instances.Unit.Base Node;

  private const int _unit_radius = 5;
  private const int _angle_marker_length = 50;

  private void _DrawPosition() => this.DrawCircle(
    this.Node.Position,
    _unit_radius,
    Godot.Colors.Green,
    false,
    1);

  private void _DrawAngle() => this.DrawLine(
    this.Node.Position,
    this.Node.Position + new Godot.Vector2(
      Mathf.Cos(this.Node.Position4D().T),
      Mathf.Sin(this.Node.Position4D().T)) * _angle_marker_length,
    Godot.Colors.Green,
    1);

  private void _DrawNext()
  {
    Godot.Vector3I? ni = this.Node._path.Next();
    if (ni.HasValue)
    {
      this.DrawLine(
        DF.Lib.Position.Transformation.Project(this.Node.Position4D().P),
        DF.Lib.Position.Transformation.Project(
          DF.Lib.Position.Transformation.ToWorld(ni.Value)),
        Godot.Colors.White,
        1);
    }
  }

  private void _DrawPath()
  {
    List<Godot.Vector3I> path = this.Node._path.P();
    if (path.Count == 0)
    {
      return;
    }

    Godot.Vector3I p = path[0];
    for (var i = 1; i < path.Count; i++)
    {
      Godot.Vector3I q = path[i];
      this.DrawLine(
        DF.Lib.Position.Transformation.Project(DF.Lib.Position.Transformation.ToWorld(p)),
        DF.Lib.Position.Transformation.Project(DF.Lib.Position.Transformation.ToWorld(q)),
        Godot.Colors.Black,
        1);

      p = q;
    }
  }

  public override void _Draw()
  {
    base._Draw();

    this._DrawPath();
    this._DrawNext();
    this._DrawPosition();
    this._DrawAngle();
  }

  public override void _Process(double delta)
  {
    base._Process(delta);

    this.QueueRedraw();
  }
}
