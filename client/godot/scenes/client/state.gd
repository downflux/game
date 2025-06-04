class_name DFClientState
extends DFStateBase

@onready var players: DFClientPlayers = $Players
@onready var units: DFClientUnits = $Units


func from_dict(
	partial: bool,
	data: Dictionary,
):
	if DFStateKeys.KDFPlayers in data:
		players.from_dict(partial, data[DFStateKeys.KDFPlayers])
	if DFStateKeys.KDFUnits in data:
		units.from_dict(partial, data[DFStateKeys.KDFUnits])


func _process(_delta):
	is_dirty = false
