namespace DF.Lib.Command;


public abstract class Base : ICommand
{
  protected DF.Lib.Tween.State _tween = new();

  public Base() {
    this._tween.Add([
        new(0, DF.Lib.State.Unknown, null),
    ]);
  }

  public virtual DF.Lib.State State(ulong t) => this._tween.Get(t)!.Value.V;

  public void SetState(
      ulong t,
      DF.Lib.State v) => this._tween.Add([
        new(t, v, false),
      ]);

  public abstract void Execute(ulong t);

  public abstract void Reconcile(ulong t);

  public virtual void Cancel(ulong t) {
    this.SetState(t, DF.Lib.State.Canceled);
  }
}
