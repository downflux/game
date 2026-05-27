# DownFlux Model
----

This directory is for all classes which store explicit state as `Godot.Node`
instances. Data may be mutated, but must not be directly called by the user --
entrypoints into data mutation ops must be via the [controller](/controller/)
directory.