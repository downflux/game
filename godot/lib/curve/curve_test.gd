# TODO(minkezhang): Migrate to GUT test framework.
extends Node


func test_step_pre():
	assert(DFCurveUtils.get_value($SimpleBoolStep, -1) == false)


func test_step_post():
	assert(DFCurveUtils.get_value($SimpleBoolStep, 1000) == true)


func test_step_interpolate():
	assert(DFCurveUtils.get_value($SimpleBoolStep, 101) == false)


func test_linear_pre():
	assert(DFCurveUtils.get_value($SimpleFloatLinear, -1) == 10)


func test_linear_post():
	assert(DFCurveUtils.get_value($SimpleFloatLinear, 1000) == 20)


func test_linear_interpolate():
	assert(DFCurveUtils.get_value($SimpleFloatLinear, 101) == 11)


func _ready():
	test_step_pre()
	test_step_post()
	test_step_interpolate()
	
	test_linear_pre()
	test_linear_post()
	test_linear_interpolate()
