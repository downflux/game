extends Node

@export var verbosity: Logger.VERBOSITY_LEVEL = Logger.VERBOSITY_LEVEL.INFO
@export var use_native_logging: bool = true
@export var host: String = "localhost"
@export var port: int = 7777


func _ready():
	Logger.verbosity = verbosity
	Logger.use_native = use_native_logging

	Server.connect_to_server(host, port)
