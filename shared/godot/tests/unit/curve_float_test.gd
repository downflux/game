extends GdUnitTestSuite


func _create_float_curve(
	data: Dictionary[int, float],
	curve_type: DFCurveBase.Type,
	default_value: float
) -> DFCurveFloat:
	var c: DFCurveFloat = DFCurveFloat.new()
	add_child(c)
	
	var timestamps_msec = data.keys()
	timestamps_msec.sort()
	
	c.timestamps_msec = timestamps_msec
	c.data = data
	c.curve_type = curve_type
	c.default_value = default_value
	
	return c


func test_linear_get_value():
	var c: DFCurveFloat = _create_float_curve(
		{
			100: 10,
			110: 11,
			120: 12,
		},
		DFCurveBase.Type.TYPE_LINEAR,
		0,
	)
	
	assert_float(c.get_value(0)).is_equal_approx(0, 1e-5)
	assert_float(c.get_value(100)).is_equal_approx(10, 1e-5)
	assert_float(c.get_value(101)).is_equal_approx(10.1, 1e-5)
	assert_float(c.get_value(130)).is_equal_approx(12, 1e-5)
