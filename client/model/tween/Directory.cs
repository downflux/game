using System.Collections.Generic;

namespace DF.Model.Tween;

public partial class Directory : Godot.Node
{
  private static Directory? _singleton;

  public static Directory S() => Directory._singleton!;

  private Dictionary<string, DF.Lib.Tween.INode> _tweens = [];
  private DF.Lib.Timer.D _timer = () => DF.Model.Timer.Server.S();

  public override void _Ready()
  {
    base._Ready();

    Directory._singleton = this;
  }

  public void Enqueue(DF.Lib.Tween.INode n)
  {
    this._tweens[n.ID()] = n;

    n.Flush();
  }

  public void Dequeue(string id)
  {
    this._tweens.Remove(id);
  }

  public override void _Process(double delta)
  {
    base._Process(delta);

    foreach (var (_, n) in this._tweens)
    {
      n.Process(this._timer().PrevTick(), this._timer().CurrTick());
    }
  }
}