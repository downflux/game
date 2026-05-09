namespace DF.Lib.Position;

public enum ProjectionMode
{
  Overhead = 0,
  Isometric = 1,
}

public class Transformation
{
  public static Godot.Vector3 ToWorld(Godot.Vector3I c)
  {
    // TODO(minkezhang): Implement.
    return (Godot.Vector3)c;
  }

  public static Godot.Vector3I ToCell(Godot.Vector3 w)
  {
    // TODO(minkezhang): Implement.
    return (Godot.Vector3I)w;
  }

  public static Godot.Vector2 Project(Godot.Vector3 w, ProjectionMode mode = ProjectionMode.Overhead)
  {
    return new(w.X, w.Y);
  }
}