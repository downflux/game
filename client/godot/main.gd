extends Node

@export var logger_verbosity: Logger.VerbosityLevel = Logger.VerbosityLevel.INFO
@export var logger_message_type: Logger.MessageType = Logger.MessageType.TYPE_SIGNAL


func _ready():
	Logger.verbosity = logger_verbosity
	Logger.message_type = logger_message_type
