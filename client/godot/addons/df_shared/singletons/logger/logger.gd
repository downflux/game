class_name DFLogger
extends Node
## Log defines logging utility functions.
##
## This scene should be imported as a singleton. This scene does not offer
## a wrapper for the "assert" keyword.

## Defines the minimum verbosity of messages. Messages below this verbosity are
## not shown in logs.
@export var verbosity: VerbosityLevel = VerbosityLevel.INFO

## If set to [code]MessageType.TYPE_NATIVE[/code], use the default Godot logging
## functions.
@export var message_type: MessageType = MessageType.TYPE_NATIVE

signal message_logged(s: String)

enum MessageType {
	TYPE_NATIVE    = 1 << 1,
	TYPE_FRAMEWORK = 1 << 2,
	TYPE_SIGNAL    = 1 << 4,
}

enum VerbosityLevel {
	DEBUG,
	INFO,
	WARNING,
	ERROR,
	NONE,
}

var _verbosity_prefix: Dictionary = {
	VerbosityLevel.DEBUG:   "D",
	VerbosityLevel.INFO:    "I",
	VerbosityLevel.WARNING: "W",
	VerbosityLevel.ERROR:   "E",
}


func _log(level: VerbosityLevel, s: String):
	if level < verbosity:
		return
	
	var timestamp = Time.get_time_string_from_system(true)
	var frame = get_stack()[2]
	var stack = "%s(%s):%s" % [frame["source"].split("/")[-1], frame["function"], frame["line"]]
	
	if message_type & MessageType.TYPE_SIGNAL:
		message_logged.emit("%s%s %s: %s" % [_verbosity_prefix.get(level, "U"), timestamp, stack, s])
	
	if message_type & MessageType.TYPE_FRAMEWORK:
		print("%s%s %s: %s" % [_verbosity_prefix.get(level, "U"), timestamp, stack, s])
	
	if message_type & MessageType.TYPE_NATIVE:
		match level:
			VerbosityLevel.DEBUG:
				print_debug("%s%s %s: %s" % [_verbosity_prefix.get(level, "U"), timestamp, stack, s])
			VerbosityLevel.INFO:
				print("%s%s %s: %s" % [_verbosity_prefix.get(level, "U"), timestamp, stack, s])
			VerbosityLevel.WARNING:
				push_warning("%s: %s" % [timestamp, s])
			VerbosityLevel.ERROR:
				push_error("%s: %s" % [timestamp, s])


func debug(s: String):
	_log(VerbosityLevel.DEBUG, s)


func info(s: String):
	_log(VerbosityLevel.INFO, s)


func warning(s: String):
	_log(VerbosityLevel.WARNING, s)


func error(s: String):
	_log(VerbosityLevel.ERROR, s)
