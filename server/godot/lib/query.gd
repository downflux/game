class_name DFQuery
extends Node


static func generate(filters: DFEnums.DataFilter) -> Dictionary:
	var q = {
		DFStateKeys.KDFState: {
		}
	}
	
	if filters & DFEnums.DataFilter.FILTER_PLAYERS:
		q[DFStateKeys.KDFState].merge({
			DFStateKeys.KDFPlayers: {
				DFStateKeys.KDFPlayerID: true,
				DFStateKeys.KDFPlayerUsername: true,
				DFStateKeys.KDFPlayerFaction:  true,
			}
		})
		if filters & DFEnums.DataFilter.FILTER_CURVES:
			q[DFStateKeys.KDFState][DFStateKeys.KDFPlayers].merge({
				DFStateKeys.KDFPlayerMoney: true,
			})
	
	if filters & DFEnums.DataFilter.FILTER_UNITS:
		q[DFStateKeys.KDFState].merge({
			DFStateKeys.KDFUnits: {
				DFStateKeys.KDFUnitID: true,
				DFStateKeys.KDFUnitType: true,
				DFStateKeys.KDFUnitFaction: true,
			}
		})
		if filters & DFEnums.DataFilter.FILTER_CURVES:
			q[DFStateKeys.KDFState][DFStateKeys.KDFUnits].merge({
				DFStateKeys.KDFUnitMapLayer: true,
				DFStateKeys.KDFUnitPosition: true,
				DFStateKeys.KDFUnitTheta:    true,
				DFStateKeys.KDFUnitHealth:   true,
			})
	return q
