namespace DF.Lib.Command;

public interface ICommand
{
  public void SetState(ulong t, DF.Lib.State v);
  public DF.Lib.State State(ulong t);
  public void Reconcile(ulong t);
  public void Cancel(ulong t);
  public void Execute(ulong t);
}
