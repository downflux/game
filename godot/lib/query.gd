extends Node
class_name DFQuery


static func generate(filters: DFEnums.DataFilter) -> Dictionary:
	var q = {
		DFStateKeys.KDFState: {
		}
	}
	
	if filters & DFEnums.DataFilter.FILTER_PLAYERS == DFEnums.DataFilter.FILTER_PLAYERS:
		q[DFStateKeys.KDFState] = {
			DFStateKeys.KDFPlayers: {
				DFStateKeys.KDFPlayerUsername: true,
				DFStateKeys.KDFPlayerFaction: true,
			}
		}
		if filters & DFEnums.DataFilter.FILTER_CURVES == DFEnums.DataFilter.FILTER_CURVES:
			q[DFStateKeys.KDFState][DFStateKeys.KDFPlayers].merge({
				DFStateKeys.KDFPlayerMoney: true,
			})
	
	return q
