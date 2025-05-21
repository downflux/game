extends Node
class_name DFQuery


static func generate(filters: DFEnums.DataFilter) -> Dictionary:
	var q = {
		DFStateKeys.KDFState: {
			DFStateKeys.KDFPlayers: {
				DFStateKeys.KDFPlayerMoney: true,
			},
			DFStateKeys.KDFUnits: {
			},
			DFStateKeys.KDFBuildings: {
			},
		},
	}
	
	if filters & DFEnums.DataFilter.FILTER_PLAYERS == DFEnums.DataFilter.FILTER_NONE:
		q[DFStateKeys.KDFState][DFStateKeys.KDFPlayers] = {}
	if filters & DFEnums.DataFilter.FILTER_UNITS == DFEnums.DataFilter.FILTER_NONE:
		q[DFStateKeys.KDFState][DFStateKeys.KDFUnits] = {}
	if filters & DFEnums.DataFilter.FILTER_BUILDINGS == DFEnums.DataFilter.FILTER_NONE:
		q[DFStateKeys.KDFState][DFStateKeys.KDFBuildings] = {}
	if filters == DFEnums.DataFilter.FILTER_NONE:
		q[DFStateKeys.KDFState] = {}
	
	return q
