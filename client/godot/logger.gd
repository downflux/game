extends Label


var _BUFFER_SIZE = 10
var _buf: Array[String]


func _on_message_logged(s: String):
	_buf.append_array(s.split("\n"))
	_buf.reverse()
	_buf.resize(min(_BUFFER_SIZE, len(_buf)))
	_buf.reverse()
	text = "\n".join(_buf)


func _ready():
	position.y = (
		get_viewport().size.y
	) - (
		_BUFFER_SIZE - 1
	) * (
		label_settings.font_size + label_settings.line_spacing
	)
	Logger.message_logged.connect(_on_message_logged)
