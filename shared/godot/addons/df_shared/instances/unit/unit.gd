class_name DFUnitBase
extends DFStateBase
## Base unit class definition.

@onready var map_layer: DFCurveInt = $MapLayer
@onready var x: DFCurveFloat       = $X
@onready var y: DFCurveFloat       = $Y
@onready var theta: DFCurveFloat   = $Theta
@onready var health: DFCurveInt    = $Health

# Game state properties

var unit_type: DFEnums.UnitType


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
		map_layer.is_dirty or not partial
	):
		data[DFStateKeys.KDFUnitMapLayer] = map_layer.to_dict(sid, partial, {})
	
	if query.get(DFStateKeys.KDFUnitX, false) and (
		x.is_dirty or not partial
	):
		data[DFStateKeys.KDFUnitX] = x.to_dict(sid, partial, {})
	
	if query.get(DFStateKeys.KDFUnitY, false) and (
		y.is_dirty or not partial
	):
		data[DFStateKeys.KDFUnitY] = y.to_dict(sid, partial, {})
	
	if query.get(DFStateKeys.KDFUnitTheta, false) and (
		theta.is_dirty or not partial
	):
		data[DFStateKeys.KDFUnitTheta] = theta.to_dict(sid, partial, {})
	
	if query.get(DFStateKeys.KDFUnitHealth, false) and (
		health.is_dirty or not partial
	):
		data[DFStateKeys.KDFUnitHealth] = health.to_dict(sid, partial, {})
	
	return data


func from_dict(partial: bool, data: Dictionary):
	if DFStateKeys.KDFIsFreed in data:
		is_deleted = true
		return
	
	if DFStateKeys.KDFUnitType in data and not partial:
		unit_type = data[DFStateKeys.KDFUnitType]
	
	if DFStateKeys.KDFUnitMapLayer in data:
		map_layer.from_dict(partial, data[DFStateKeys.KDFUnitMapLayer])

	if DFStateKeys.KDFUnitX in data:
		x.from_dict(partial, data[DFStateKeys.KDFUnitX])

	if DFStateKeys.KDFUnitY in data:
		y.from_dict(partial, data[DFStateKeys.KDFUnitY])

	if DFStateKeys.KDFUnitTheta in data:
		theta.from_dict(partial, data[DFStateKeys.KDFUnitTheta])

	if DFStateKeys.KDFUnitHealth in data:
		health.from_dict(partial, data[DFStateKeys.KDFUnitHealth])
