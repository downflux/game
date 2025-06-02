class_name DFPlayer
extends DFStateBase
## Defines the totality of the player game state.
## [br][br]
## This state contains both user authentication details (e.g. login mint) as
## well as game state, e.g. the current money of the player, etc.

var username: String
var faction: DFEnums.Faction
var money: DFCurveInt = DFCurveInt.new(DFCurveBase.Type.TYPE_LINEAR)


# Serialize data to be exported when e.g. saving game and communicating with
# client.
func to_dict(sid: int, partial: bool, query: Dictionary) -> Dictionary:
	if partial and not is_dirty:
		return {}
	
	if is_deleted:
		return {
			DFStateKeys.KDFIsFreed: is_deleted,
		}
	
	var data = {}
	
	if query.get(DFStateKeys.KDFPlayerUsername, false):
		data[DFStateKeys.KDFPlayerUsername] = username
	if query.get(DFStateKeys.KDFPlayerFaction, false):
		data[DFStateKeys.KDFPlayerFaction] = faction
	if query.get(DFStateKeys.KDFPlayerMoney, false):
		if not partial or (
			partial and money.is_dirty
		):
			data[DFStateKeys.KDFPlayerMoney] = money.to_dict(sid, partial, {})

	return data
