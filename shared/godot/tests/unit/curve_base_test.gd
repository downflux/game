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
	
	assert_int(c._get_next_timestamp_index(0)).is_equal(0)
	assert_int(c._get_next_timestamp_index(105)).is_equal(1)
	assert_int(c._get_next_timestamp_index(110)).is_equal(1)
	assert_int(c._get_next_timestamp_index(125)).is_equal(-1)


func test_get_next_timestamp():
	var c: DFCurveFloat = _create_float_curve(
		{
			100: 10,
			110: 11,
			120: 12,
		},
		DFCurveBase.Type.TYPE_STEP,
		false,
	)
	
	assert_int(c.get_next_timestamp(0)).is_equal(100)
	assert_int(c.get_next_timestamp(105)).is_equal(110)
	assert_int(c.get_next_timestamp(110)).is_equal(110)
	assert_int(c.get_next_timestamp(125)).is_equal(-1)


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
	assert_int(c._get_prev_timestamp_index(110)).is_equal(0)
	assert_int(c._get_prev_timestamp_index(125)).is_equal(2)


func test_get_prev_timestamp():
	var c: DFCurveFloat = _create_float_curve(
		{
			100: 10,
			110: 11,
			120: 12,
		},
		DFCurveBase.Type.TYPE_STEP,
		false,
	)
	
	assert_int(c.get_prev_timestamp(0)).is_equal(-1)
	assert_int(c.get_prev_timestamp(105)).is_equal(100)
	assert_int(c.get_prev_timestamp(110)).is_equal(100)
	assert_int(c.get_prev_timestamp(125)).is_equal(120)


func test_add_keyframe():
	var c: DFCurveFloat = _create_float_curve(
		{
			100: 10,
			110: 11,
			120: 12,
		},
		DFCurveBase.Type.TYPE_LINEAR,
		0,
	)
	
	c.add_keyframe(0, 0.1)
	c.add_keyframe(101, 10.1)
	c.add_keyframe(110, 11.1)
	c.add_keyframe(130, 13)
	
	assert_array(c.timestamps_msec).is_equal([0, 100, 101, 110, 120, 130])
	assert_dict(c.data).is_equal({
		0:   0.1,
		100: 10.0,
		101: 10.1,
		110: 11.1,
		120: 12.0,
		130: 13.0,
	})


func test_erase_keyframe():
	var c: DFCurveFloat = _create_float_curve(
		{
			100: 10,
			110: 11,
			120: 12,
		},
		DFCurveBase.Type.TYPE_LINEAR,
		0,
	)
	
	c.erase_keyframe(0)
	c.erase_keyframe(130)
	c.erase_keyframe(110)
	
	assert_array(c.timestamps_msec).is_equal([100, 120])
	assert_dict(c.data).is_equal({
		100: 10.0,
		120: 12.0,
	})


func test_trim_keyframes_noop():
	var c: DFCurveFloat = _create_float_curve(
		{
			100: 10,
			110: 11,
			120: 12,
		},
		DFCurveBase.Type.TYPE_LINEAR,
		0,
	)
	
	c.trim_keyframes(100, true)
	c.trim_keyframes(120, false)
	
	assert_array(c.timestamps_msec).is_equal([100, 110, 120])
	assert_dict(c.data).is_equal({
		100: 10.0,
		110: 11.0,
		120: 12.0,
	})


func test_trim_keyframes_before():
	var c: DFCurveFloat = _create_float_curve(
		{
			100: 10,
			110: 11,
			120: 12,
		},
		DFCurveBase.Type.TYPE_LINEAR,
		0,
	)
	
	c.trim_keyframes(110, true)
	
	assert_array(c.timestamps_msec).is_equal([110, 120])
	assert_dict(c.data).is_equal({
		110: 11.0,
		120: 12.0,
	})


func test_trim_keyframes_before_no_exact_match():
	var c: DFCurveFloat = _create_float_curve(
		{
			100: 10,
			110: 11,
			120: 12,
		},
		DFCurveBase.Type.TYPE_LINEAR,
		0,
	)
	
	c.trim_keyframes(109, true)
	
	assert_array(c.timestamps_msec).is_equal([110, 120])
	assert_dict(c.data).is_equal({
		110: 11.0,
		120: 12.0,
	})


func test_trim_keyframes_before_first():
	var c: DFCurveFloat = _create_float_curve(
		{
			100: 10,
			110: 11,
			120: 12,
		},
		DFCurveBase.Type.TYPE_LINEAR,
		0,
	)
	
	c.trim_keyframes(121, true)
	
	assert_array(c.timestamps_msec).is_equal([])
	assert_dict(c.data).is_equal({})


func test_trim_keyframes_after():
	var c: DFCurveFloat = _create_float_curve(
		{
			100: 10,
			110: 11,
			120: 12,
		},
		DFCurveBase.Type.TYPE_LINEAR,
		0,
	)
	
	c.trim_keyframes(110, false)
	
	assert_array(c.timestamps_msec).is_equal([100, 110])
	assert_dict(c.data).is_equal({
		100: 10.0,
		110: 11.0,
	})


func test_trim_keyframes_after_no_exact_match():
	var c: DFCurveFloat = _create_float_curve(
		{
			100: 10,
			110: 11,
			120: 12,
		},
		DFCurveBase.Type.TYPE_LINEAR,
		0,
	)
	
	c.trim_keyframes(111, false)
	
	assert_array(c.timestamps_msec).is_equal([100, 110])
	assert_dict(c.data).is_equal({
		100: 10.0,
		110: 11.0,
	})


func test_trim_keyframes_after_last():
	var c: DFCurveFloat = _create_float_curve(
		{
			100: 10,
			110: 11,
			120: 12,
		},
		DFCurveBase.Type.TYPE_LINEAR,
		0,
	)
	
	c.trim_keyframes(0, false)
	
	assert_array(c.timestamps_msec).is_equal([])
	assert_dict(c.data).is_equal({})
