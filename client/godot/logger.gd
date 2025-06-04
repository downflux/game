extends Label


func _on_message_logged(s: String):
	text = s


func _ready():
	Logger.message_logged.connect(_on_message_logged)
