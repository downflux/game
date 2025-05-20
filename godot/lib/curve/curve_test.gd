# TODO(minkezhang): Migrate to GUT test framework.
extends Node


func test_step_pre():
	assert($SimpleBoolStep.get_value(0) == false)


func test_step_post():
	assert($SimpleBoolStep.get_value(1000) == true)


func test_step_interpolate():
	assert($SimpleBoolStep.get_value(101) == false)


func test_linear_pre():
	assert($SimpleFloatLinear.get_value(-1) == 10)


func test_linear_post():
	assert($SimpleFloatLinear.get_value(1000) == 20)


func test_linear_interpolate():
	assert($SimpleFloatLinear.get_value(101) == 11)


func _ready():
	test_step_pre()
	test_step_post()
	test_step_interpolate()
	
	test_linear_pre()
	test_linear_post()
	test_linear_interpolate()
