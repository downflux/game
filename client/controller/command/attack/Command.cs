/*
using System;

namespace DF.Controller.Command.Attack;

public class Command
{
  private DF.Model.Unit.Base _src;
  private DF.Model.Unit.Base _dst;
  private State _attack;
  internal DF.Lib.Timer.D _timer = () => DF.Model.Timer.Server.S();
  private string _id = "";

  public Command(State attack, DF.Model.Unit.Base src, DF.Model.Unit.Base dst)
  {
    this._src = src;
    this._dst = dst;
    this._attack = attack;

    this._src.Moveable()._position.KeyFrameTriggerEvent += this._TurnCompletedHandler;
  }

  private void _TurnCompletedHandler(
    object sender,
    DF.Lib.Tween.KeyframeTriggerEventHandlerArgs<DF.Lib.Position.Position, DF.Lib.Path.FrameData> e)
  {
    if (this._id == "")
    {
      return;
    }

    if (e.F.D.T.HasFlag(Lib.Path.KeyFrameType.CompletedTurn) && e.F.D.ID == this._id)
    {
      this._id = "";
      this._attack.Attack(this._dst.HealthPool());  // attack should worry about ready curves -- enqueue this command in state
    }
  }

  public void Execute()
  {
    if (this._id != "")
    {
      return;
    }

    this._attack.AddTrigger(...)
    // wait for ready and then attack
    this._id = Guid.NewGuid().ToString();

    var p = this._src.Moveable()._path.Cells();
    this._src.Moveable().Stop();
    this._src.Moveable()._position.Add(
      DF.Lib.Path.Generator.Rotate(
        this._id,
        this._src.Moveable().Position(),
        this._dst.Moveable().Position(),
        this._timer().CurrTick(),
        this._src.Moveable().Velocity()));
  }
}

*/