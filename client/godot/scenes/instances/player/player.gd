class_name DFClientPlayer
extends DFStateBase

@onready var player_state: DFPlayer = $Player

## If set to true, this is the player interacting with this instance of the
## client.
var is_self: bool


func from_dict(
	partial: bool,
	data: Dictionary,
):
	if DFStateKeys.KDFIsFreed in data:
		self.is_deleted = true
		return
	
	player_state.from_dict(partial, data)
