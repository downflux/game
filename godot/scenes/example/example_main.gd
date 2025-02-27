extends DFExampleNode


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Calling Example from within GDScript")
	simple_function()  # From DFExampleNode.SimpleFunction
