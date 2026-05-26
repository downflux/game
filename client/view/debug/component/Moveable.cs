using System.Collections.Generic;
using Godot;

namespace DF.View.Debug.Component;

public partial class Moveable : Godot.Node2D
{
  [Godot.Export]
  public DF.Model.Component.Moveable? Node;

  [Godot.Export]
  public Godot.Vector2I Dimension;

  private DF.View.Debug.Tween.Float<DF.Lib.Path.FrameData> _angle = new() { Label = "Orientation" };

  private const int _unit_radius = 5;
  private const int _angle_marker_length = 50;
  public override void _Ready()
  {
    base._Ready();
    this._angle.Dimension = this.Dimension;
    this.AddChild(this._angle);

    if (this.Node == null)
    {
      return;
    }

    this.SetNode(this.Node);
  }

  public void SetNode(DF.Model.Component.Moveable n)
  {
    this.Node = n;
    this._angle.Tween = new DF.View.Debug.Tween.Angle.ToFloat(n._position);
  }

  private void _DrawPosition()
  {
    if (this.Node == null)
    {
      return;
    }

    this.DrawCircle(
      DF.Lib.Position.Transformation.Project(this.Node.Position().P),
      _unit_radius,
      Godot.Colors.Green,
      false,
      1);
  }

  private void _DrawAngle()
  {
    if (this.Node == null)
    {
      return;
    }

    this.DrawLine(
      DF.Lib.Position.Transformation.Project(this.Node.Position().P),
      DF.Lib.Position.Transformation.Project(this.Node.Position().P) + new Godot.Vector2(
        Mathf.Cos(this.Node.Position().T),
        Mathf.Sin(this.Node.Position().T)) * _angle_marker_length,
      Godot.Colors.Green,
      1);
  }

  private void _DrawNext()
  {
    if (this.Node == null)
    {
      return;
    }

    Godot.Vector3I? ni = this.Node._path.Next();
    if (ni.HasValue)
    {
      this.DrawLine(
        DF.Lib.Position.Transformation.Project(this.Node.Position().P),
        DF.Lib.Position.Transformation.Project(
          DF.Lib.Position.Transformation.ToWorld(ni.Value)),
        Godot.Colors.Red,
        1);
    }
  }

  private void _DrawPath()
  {
    if (this.Node == null)
    {
      return;
    }

    List<Godot.Vector3I> path = this.Node._path.Cells();
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
        Godot.Colors.Gray,
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