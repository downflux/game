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

func test_get_next_timestamp_index():
	var c: DFCurveFloat = _create_float_curve(
		{
			100: 10,
			110: 11,
			120: 12,
		},
		DFCurveBase.Type.TYPE_STEP,
		false,
	)
	
	# The next timestamp for time before first timestamp will return the first
	# recorded timestamp.
	assert_int(c._get_next_timestamp_index(0)).is_equal(0)
	
	assert_int(c._get_next_timestamp_index(105)).is_equal(1)
	
	# get_next_timestamp filters for a strictly greater than association.
	assert_int(c._get_next_timestamp_index(110)).is_equal(2)
	
	# No valid timestamp exists for time past the last recorded timestamp.
	assert_int(c._get_next_timestamp_index(125)).is_equal(-1)


func test_get_prev_timestamp_index():
	var c: DFCurveFloat = _create_float_curve(
		{
			100: 10,
			110: 11,
			120: 12,
		},
		DFCurveBase.Type.TYPE_STEP,
		false,
	)
	
	assert_int(c._get_prev_timestamp_index(0)).is_equal(-1)
	assert_int(c._get_prev_timestamp_index(105)).is_equal(0)
	assert_int(c._get_prev_timestamp_index(110)).is_equal(1)
	assert_int(c._get_prev_timestamp_index(125)).is_equal(2)


func test_add_data():
	var c: DFCurveFloat = _create_float_curve(
		{
			100: 10,
			110: 11,
			120: 12,
		},
		DFCurveBase.Type.TYPE_LINEAR,
		0,
	)
	
	c.add_data(0, 0.1)
	c.add_data(101, 10.1)
	c.add_data(110, 11.1)
	c.add_data(130, 13)
	
	assert_array(c.timestamps_msec).is_equal([0, 100, 101, 110, 120, 130])
	assert_dict(c.data).is_equal({
		0:   0.1,
		100: 10.0,
		101: 10.1,
		110: 11.1,
		120: 12.0,
		130: 13.0,
	})


func test_erase_data():
	var c: DFCurveFloat = _create_float_curve(
		{
			100: 10,
			110: 11,
			120: 12,
		},
		DFCurveBase.Type.TYPE_LINEAR,
		0,
	)
	
	c.erase_data(0)
	c.erase_data(130)
	c.erase_data(110)
	
	assert_array(c.timestamps_msec).is_equal([100, 120])
	assert_dict(c.data).is_equal({
		100: 10.0,
		120: 12.0,
	})


func test_trim_data_noop():
	var c: DFCurveFloat = _create_float_curve(
		{
			100: 10,
			110: 11,
			120: 12,
		},
		DFCurveBase.Type.TYPE_LINEAR,
		0,
	)
	
	c.trim_data(0, true)
	c.trim_data(120, false)
	
	assert_array(c.timestamps_msec).is_equal([100, 110, 120])
	assert_dict(c.data).is_equal({
		100: 10.0,
		110: 11.0,
		120: 12.0,
	})


func test_trim_data_before():
	var c: DFCurveFloat = _create_float_curve(
		{
			100: 10,
			110: 11,
			120: 12,
		},
		DFCurveBase.Type.TYPE_LINEAR,
		0,
	)
	
	c.trim_data(110, true)
	
	assert_array(c.timestamps_msec).is_equal([110, 120])
	assert_dict(c.data).is_equal({
		110: 11.0,
		120: 12.0,
	})


func test_trim_data_before_no_exact_match():
	var c: DFCurveFloat = _create_float_curve(
		{
			100: 10,
			110: 11,
			120: 12,
		},
		DFCurveBase.Type.TYPE_LINEAR,
		0,
	)
	
	c.trim_data(109, true)
	
	assert_array(c.timestamps_msec).is_equal([110, 120])
	assert_dict(c.data).is_equal({
		110: 11.0,
		120: 12.0,
	})


func test_trim_data_before_all():
	var c: DFCurveFloat = _create_float_curve(
		{
			100: 10,
			110: 11,
			120: 12,
		},
		DFCurveBase.Type.TYPE_LINEAR,
		0,
	)
	
	c.trim_data(121, true)
	
	assert_array(c.timestamps_msec).is_equal([])
	assert_dict(c.data).is_equal({})


func test_trim_data_after():
	var c: DFCurveFloat = _create_float_curve(
		{
			100: 10,
			110: 11,
			120: 12,
		},
		DFCurveBase.Type.TYPE_LINEAR,
		0,
	)
	
	c.trim_data(110, false)
	
	assert_array(c.timestamps_msec).is_equal([100, 110])
	assert_dict(c.data).is_equal({
		100: 10.0,
		110: 11.0,
	})


func test_trim_data_after_no_exact_match():
	var c: DFCurveFloat = _create_float_curve(
		{
			100: 10,
			110: 11,
			120: 12,
		},
		DFCurveBase.Type.TYPE_LINEAR,
		0,
	)
	
	c.trim_data(111, false)
	
	assert_array(c.timestamps_msec).is_equal([100, 110])
	assert_dict(c.data).is_equal({
		100: 10.0,
		110: 11.0,
	})


func test_trim_data_after_all():
	var c: DFCurveFloat = _create_float_curve(
		{
			100: 10,
			110: 11,
			120: 12,
		},
		DFCurveBase.Type.TYPE_LINEAR,
		0,
	)
	
	c.trim_data(0, false)
	
	assert_array(c.timestamps_msec).is_equal([])
	assert_dict(c.data).is_equal({})
