using GdUnit4;
using static GdUnit4.Assertions;

namespace DF.Benchmarks.Lib.Tween;

[TestSuite]
public class BaseBenchmark
{
	[TestCase(Iterations = 10)]
	public void BenchmarkGet()
	{
		DF.Lib.Tween.Base<float, bool> x = new(DF.Lib.Tween.InterpolationType.Linear);

		ulong n_points = 1000;
		ulong n_runs = 1000000;
		int server_tps = 10;
		ulong granularity = 1000;

		for (ulong i = 0; i < n_points; i++)
		{
			x.Add([
				new((ulong)i * granularity, i, false)
			]);
		}
		x.Flush();

		System.Random seed = new System.Random();

		System.DateTime start = System.DateTime.Now;
		for (ulong i = 0; i < n_runs; i++)
		{
			x.Get((ulong)seed.Next((int)(n_points * granularity)));
		}
		double elapsed = System.DateTime.Now.Subtract(start).TotalSeconds;
		double n_frames = elapsed * server_tps;

		// TODO(minkezhang): Write benchmark hook.
		AssertThat((double)(n_runs) / n_frames).IsGreater(100000);
	}
}
