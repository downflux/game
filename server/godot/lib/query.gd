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
				DFStateKeys.KDFUnitID:   true,
				DFStateKeys.KDFUnitType: true,
			}
		})
		if filters & DFEnums.DataFilter.FILTER_CURVES:
			q[DFStateKeys.KDFState][DFStateKeys.KDFUnits].merge({
				DFStateKeys.KDFUnitMapLayer: true,
				DFStateKeys.KDFUnitX:        true,
				DFStateKeys.KDFUnitY:        true,
				DFStateKeys.KDFUnitTheta:    true,
				DFStateKeys.KDFUnitHealth:   true,
			})
	return q
