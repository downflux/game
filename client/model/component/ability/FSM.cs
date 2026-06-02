namespace DF.Model.Component.Ability;

public enum FSM
{
  None = 0,
  Cooldown = 1,
  Queued = 2,  // Someone is waiting for the next charge.
  Ready = 3,
}