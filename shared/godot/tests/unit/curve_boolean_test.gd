extends GdUnitTestSuite


func _create_bool_curve(
	data: Dictionary[int, bool],
	curve_type: DFCurveBase.Type,
	default_value: bool
) -> DFCurveBoolean:
	var c: DFCurveBoolean = DFCurveBoolean.new()
	add_child(c)
	
	var timestamps_msec = data.keys()
	timestamps_msec.sort()
	
	c.timestamps_msec = timestamps_msec
	c.data = data
	c.curve_type = curve_type
	c.default_value = default_value
	
	return c


func test_step_get_value():
	var c: DFCurveBoolean = _create_bool_curve(
		{10: true},
		DFCurveBase.Type.TYPE_STEP,
		false,
	)
	
	assert_bool(c.get_value(0)).is_false()
	assert_bool(c.get_value(10)).is_true()
	assert_bool(c.get_value(100)).is_true()
