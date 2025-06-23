class_name DFClientPlayer
extends DFStateBase

@onready var player_state: DFPlayer = $Player
@onready var username: Label        = $UI/Username
@onready var faction: Label         = $UI/Faction
@onready var money: Label           = $UI/Money
@onready var ui: CanvasLayer        = $UI

## If set to true, this is the player interacting with this instance of the
## client.
var is_self: bool:
	set(v):
		if ui != null:
			ui.visible = v
		is_self = v


func _ready():
	ui.visible = is_self


func _process(_delta):
	money.text = "$%d" % [player_state.money.get_value(Server.get_timestamp_msec())]


func from_dict(
	partial: bool,
	data: Dictionary,
):
	if not partial and DFStateKeys.KDFPlayerUsername in data:
		username.text = data[DFStateKeys.KDFPlayerUsername]
	if not partial and DFStateKeys.KDFPlayerFaction in data:
		faction.text = DFEnums.Faction.keys()[data[DFStateKeys.KDFPlayerFaction]]
	
	if DFStateKeys.KDFIsFreed in data:
		self.is_deleted = true
		return
	
	player_state.from_dict(partial, data)
