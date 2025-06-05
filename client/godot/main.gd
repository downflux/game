extends Node

@export var logger_verbosity: Logger.VerbosityLevel = Logger.VerbosityLevel.INFO
@export var logger_message_type: Logger.MessageType = Logger.MessageType.TYPE_SIGNAL

@onready var client: DFClient = $Client

func _ready():
	Logger.verbosity = logger_verbosity
	Logger.message_type = logger_message_type
	DFSettings.CURVE_HISTORY_LIMIT = 500
	
	client.start()
