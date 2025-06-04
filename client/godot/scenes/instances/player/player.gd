class_name DFClientPlayer
extends DFStateBase

@onready var player_state: DFPlayer = $Player


func from_dict(
	partial: bool,
	data: Dictionary,
):
	if DFStateKeys.KDFIsFreed in data:
		self.is_deleted = true
		return
	
	player_state.from_dict(partial, data)
