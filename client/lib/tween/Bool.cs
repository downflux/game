using System;

namespace DF.Lib.Tween;

public class Bool<W> : Base<bool, W>
{
	public Bool(InterpolationType t) : base(t)
	{
		if (t == InterpolationType.Linear)
		{
			throw new ArgumentException("InterpolationType cannot be of type InterpolationType.Linear", nameof(t));
		}
	}
}
