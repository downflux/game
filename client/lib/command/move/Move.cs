using System;
using System.Linq;

namespace DF.Lib.Command.Move;

protected class _MoveSegment(
    DF.Lib.Tween.Base<DF.Lib.Position.Position, DF.Lib.Path.FrameData> p,
    DF.Lib.Position.Position src,
    DF.Lib.Position.Position dst
    ) : DF.Lib.Command.Base, DF.Lib.Command.ICommand
{
    DF.Lib.Position.Position _src = src;
    DF.Lib.Position.Position _dst = dst;

    string _id = Guid.NewGuid().ToString();

    DF.Lib.Tween.Base<DF.Lib.Position.Position, DF.Lib.Path.FrameData> _position = p;

    public override void Execute(ulong t)
    {
        throw new NotImplementedException();
    }

    public override DF.Lib.State State(ulong t)
    {
        var s = base.State(t);
        switch (s)
        {
            case DF.Lib.State.Executing:
                if (this._position.KeyFrames(0, t).Where(f => f.D.ID == this._id).Any())
                {
                    return DF.Lib.State.Done;
                }
                return s;
            default:
                return s;
        }
    }
}