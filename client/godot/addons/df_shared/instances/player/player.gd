class_name DFPlayer
extends DFStateBase
## Defines the totality of the player game state.
## [br][br]
## This state contains both user authentication details (e.g. login mint) as
## well as game state, e.g. the current money of the player, etc.

@onready var money: DFCurveInt = $Money

var username: String
var faction: DFEnums.Faction


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
	
	# Read-only properties do not change and do not need to be re-broadcasted.
	if query.get(DFStateKeys.KDFPlayerUsername, false) and not partial:
		data[DFStateKeys.KDFPlayerUsername] = username
	if query.get(DFStateKeys.KDFPlayerFaction, false) and not partial:
		data[DFStateKeys.KDFPlayerFaction] = faction
	
	if query.get(DFStateKeys.KDFPlayerMoney, false) and (
		money.is_dirty or not partial
	):
			data[DFStateKeys.KDFPlayerMoney] = money.to_dict(sid, partial, {})

	return data


func from_dict(partial: bool, data: Dictionary):
	if DFStateKeys.KDFIsFreed in data:
		self.is_deleted = true
		return
	
	if DFStateKeys.KDFPlayerUsername in data and not partial:
		username = data[DFStateKeys.KDFPlayerUsername]
	
	if DFStateKeys.KDFPlayerFaction in data and not partial:
		faction = data[DFStateKeys.KDFPlayerFaction]
	
	if DFStateKeys.KDFPlayerMoney in data:
		money.from_dict(partial, data[DFStateKeys.KDFPlayerMoney])
