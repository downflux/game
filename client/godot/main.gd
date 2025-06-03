extends Node

@export var verbosity: Logger.VERBOSITY_LEVEL = Logger.VERBOSITY_LEVEL.INFO
@export var use_native_logging: bool = true


func _ready():
	Logger.verbosity = verbosity
	Logger.use_native = use_native_logging
