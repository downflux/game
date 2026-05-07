using Godot;

namespace DF.Lib.Position;

public record struct Position(Godot.Vector3 p, float t)
{
  public Godot.Vector2 XY { get; } = new(p.X, p.Y);
  public Godot.Vector3 P { get; } = p;
  public float T { get; } = t;
}

public record struct Velocity(float xy, float z, float w)
{
  public float XY { get; } = xy;
  public float Z { get; } = z;
  public float W { get; } = w;
}