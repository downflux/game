class_name DFUnitBase
extends DFStateBase
## Base unit class definition.

# Game state properties

var unit_type: DFEnums.UnitType
var map_layer: DFCurveInt = DFCurveInt.new(DFCurveBase.Type.TYPE_STEP)
var x: DFCurveFloat       = DFCurveFloat.new(DFCurveBase.Type.TYPE_LINEAR)
var y: DFCurveFloat       = DFCurveFloat.new(DFCurveBase.Type.TYPE_LINEAR)
var theta: DFCurveFloat   = DFCurveFloat.new(DFCurveBase.Type.TYPE_LINEAR)
var health: DFCurveInt    = DFCurveInt.new(DFCurveBase.Type.TYPE_LINEAR)


func to_dict(
	sid: int,
	partial: bool,
	query: Dictionary,
) -> Dictionary:
	if partial and not is_dirty:
		return {}
	
	if is_deleted:
		return {
			DFStateKeys.KDFIsFreed: is_deleted,
		}
	
	var data = {}
	
	# Read-only properties do not change and do not need to be re-broadcasted.
	if query.get(DFStateKeys.KDFUnitType, false) and not partial:
		data[DFStateKeys.KDFUnitType] = unit_type
	
	if query.get(DFStateKeys.KDFUnitMapLayer, false) and (
		not partial or (partial and map_layer.is_dirty)
	):
		data[DFStateKeys.KDFUnitMapLayer] = map_layer.to_dict(sid, partial, {})
	
	if query.get(DFStateKeys.KDFUnitX, false) and (
		not partial or (partial and x.is_dirty)
	):
		data[DFStateKeys.KDFUnitX] = x.to_dict(sid, partial, {})
	
	if query.get(DFStateKeys.KDFUnitY, false) and (
		not partial or (partial and y.is_dirty)
	):
		data[DFStateKeys.KDFUnitY] = y.to_dict(sid, partial, {})
	
	if query.get(DFStateKeys.KDFUnitTheta, false) and (
		not partial or (partial and theta.is_dirty)
	):
		data[DFStateKeys.KDFUnitTheta] = theta.to_dict(sid, partial, {})
	
	if query.get(DFStateKeys.KDFUnitHealth, false) and (
		not partial or (partial and health.is_dirty)
	):
		data[DFStateKeys.KDFUnitHealth] = health.to_dict(sid, partial, {})
	
	return data
