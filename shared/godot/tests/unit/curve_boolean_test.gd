extends GdUnitTestSuite


func _create_bool_curve(
	timestamps_msec: Array[int],
	data: Dictionary[int, bool],
	curve_type: DFCurveBase.Type,
	default_value: bool
) -> DFCurveBoolean:
	var c: DFCurveBoolean = DFCurveBoolean.new()
	add_child(c)
	
	c.timestamps_msec = timestamps_msec
	c.data = data
	c.curve_type = curve_type
	c.default_value = default_value
	
	return c


func test_get_next_timestamp_index():
	var c: DFCurveBoolean = _create_bool_curve(
		[100, 110, 120],
		{
			10: true,
			11: true,
			12: true,
		},
		DFCurveBase.Type.TYPE_STEP,
		false,
	)
	
	# The next timestamp for time before first timestamp will return the first
	# recorded timestamp.
	assert_int(c.get_next_timestamp_index(0)).is_equal(0)
	
	assert_int(c.get_next_timestamp_index(105)).is_equal(1)
	
	# get_next_timestamp filters for a strictly greater than association.
	assert_int(c.get_next_timestamp_index(110)).is_equal(2)
	
	# No valid timestamp exists for time past the last recorded timestamp.
	assert_int(c.get_next_timestamp_index(125)).is_equal(-1)


func test_get_prev_timestamp_index():
	var c: DFCurveBoolean = _create_bool_curve(
		[100, 110, 120],
		{
			10: true,
			11: true,
			12: true,
		},
		DFCurveBase.Type.TYPE_STEP,
		false,
	)
	
	assert_int(c.get_prev_timestamp_index(0)).is_equal(-1)
	assert_int(c.get_prev_timestamp_index(105)).is_equal(0)
	assert_int(c.get_prev_timestamp_index(110)).is_equal(1)
	assert_int(c.get_prev_timestamp_index(125)).is_equal(2)


func test_step_get_value():
	var c: DFCurveBoolean = _create_bool_curve(
		[10],
		{10: true},
		DFCurveBase.Type.TYPE_STEP,
		false,
	)
	
	assert_bool(c.get_value(0)).is_false()
	assert_bool(c.get_value(10)).is_true()
	assert_bool(c.get_value(100)).is_true()
