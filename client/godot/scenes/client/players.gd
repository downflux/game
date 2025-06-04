class_name DFClientPlayers
extends DFStateBase

@onready var player_scene: PackedScene = preload("res://scenes/instances/player/player.tscn")



func add_player(player: DFClientPlayer):
	is_dirty = true
	
	add_child(player, true)


func get_player(sid: int) -> DFClientPlayer:
	return get_node_or_null(str(sid))


func from_dict(
	partial: bool,
	data: Dictionary,
):
	for sid in data:
		var p: DFClientPlayer = get_player(sid)
		if p == null:
			p = player_scene.instantiate()
			p.name = str(sid)
			p.is_self = sid == multiplayer.get_unique_id()
			
			add_player(p)
		p.from_dict(partial, data[sid])
