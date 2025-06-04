class_name DFLogger
extends Node
## Log defines logging utility functions.
##
## This scene should be imported as a singleton. This scene does not offer
## a wrapper for the "assert" keyword.

## Defines the minimum verbosity of messages. Messages below this verbosity are
## not shown in logs.
@export var verbosity: VERBOSITY_LEVEL = VERBOSITY_LEVEL.INFO

## If [code]true[/code], uses the default Godot logging functions instead.
@export var use_native: bool = true

signal message_logged(s: String)

enum VERBOSITY_LEVEL {
	DEBUG,
	INFO,
	WARNING,
	ERROR,
	NONE,
}

var _verbosity_prefix: Dictionary = {
	VERBOSITY_LEVEL.DEBUG:   "D",
	VERBOSITY_LEVEL.INFO:    "I",
	VERBOSITY_LEVEL.WARNING: "W",
	VERBOSITY_LEVEL.ERROR:   "E",
}


func _log(level: VERBOSITY_LEVEL, s: String):
	if level >= verbosity:
		var timestamp = Time.get_time_string_from_system(true)
		var frame = get_stack()[2]
		var stack = "%s(%s):%s" % [frame["source"].split("/")[-1], frame["function"], frame["line"]]
		message_logged.emit("%s%s %s: %s" % [_verbosity_prefix.get(level, "U"), timestamp, stack, s])
		if not use_native:
			print("%s%s %s: %s" % [_verbosity_prefix.get(level, "U"), timestamp, stack, s])
			return
		
		match level:
			VERBOSITY_LEVEL.DEBUG:
				print_debug("%s%s %s: %s" % [_verbosity_prefix.get(level, "U"), timestamp, stack, s])
			VERBOSITY_LEVEL.INFO:
				print("%s%s %s: %s" % [_verbosity_prefix.get(level, "U"), timestamp, stack, s])
			VERBOSITY_LEVEL.WARNING:
				push_warning("%s: %s" % [timestamp, s])
			VERBOSITY_LEVEL.ERROR:
				push_error("%s: %s" % [timestamp, s])


func debug(s: String):
	_log(VERBOSITY_LEVEL.DEBUG, s)


func info(s: String):
	_log(VERBOSITY_LEVEL.INFO, s)


func warning(s: String):
	_log(VERBOSITY_LEVEL.WARNING, s)


func error(s: String):
	_log(VERBOSITY_LEVEL.ERROR, s)
