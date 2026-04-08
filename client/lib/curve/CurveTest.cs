using GdUnit4;
using static GdUnit4.Assertions;

namespace Downflux.Tests;

[TestSuite]
public class CurveTest {
		[TestCase]
		public void BenchmarkGet() {
			Downflux.Lib.Curve<float> x = new();
			
			ulong n_points = 1000;
			ulong n_runs = 1000000;
			int server_tps = 10;
			ulong granularity = 1000;
			
			for (ulong i = 0; i < n_points; i++) {
				x.Schedule((ulong) i * granularity, null, i);
			}
			x.Process(1);
			
			System.Random seed = new System.Random();
			
			System.DateTime start = System.DateTime.Now;
			for (ulong i = 0; i < n_runs; i++) {
				x.Get((ulong) seed.Next((int) (n_points * granularity)));
			}
			double elapsed = System.DateTime.Now.Subtract(start).TotalSeconds;
			double n_frames = elapsed * server_tps;
			// TODO(minkezhang): Write benchmark hook.
			AssertThat((double) (n_runs) / n_frames).IsGreater(100000);
		}
		
		[TestCase]
		public void TestGetUlong() {
			Downflux.Lib.Curve<ulong> x = new();
			x.Schedule(10, null, 110);
			x.Schedule(20, null, 120);
			x.Schedule(30, null, 130);
			x.Process(1);
			
			AssertThat(x.Get(0)).IsNull();
			AssertThat(x.Get(15)).IsEqual(((Downflux.Lib.Snapshot<ulong>) new (15, 115)));
			AssertThat(x.Get(35)).IsEqual(((Downflux.Lib.Snapshot<ulong>) new (35, 130)));
		}
		
		[TestCase]
		public void TestGetInt() {
			Downflux.Lib.Curve<int> x = new();
			x.Schedule(10, null, 110);
			x.Schedule(20, null, 120);
			x.Schedule(30, null, 130);
			x.Process(1);
			
			AssertThat(x.Get(0)).IsNull();
			AssertThat(x.Get(15)).IsEqual(((Downflux.Lib.Snapshot<int>) new (15, 115)));
			AssertThat(x.Get(35)).IsEqual(((Downflux.Lib.Snapshot<int>) new (35, 130)));
		}
		
		[TestCase]
		public void TestGetFloat() {
			Downflux.Lib.Curve<float> x = new();
			x.Schedule(10, null, 110);
			x.Schedule(20, null, 120);
			x.Schedule(30, null, 130);
			x.Process(1);
			
			AssertThat(x.Get(0)).IsNull();
			AssertThat(x.Get(15)).IsEqual(((Downflux.Lib.Snapshot<float>) new (15, 115)));
			AssertThat(x.Get(35)).IsEqual(((Downflux.Lib.Snapshot<float>) new (35, 130)));
		}
		
		[TestCase]
		public void TestLowerBound() {
			Downflux.Lib.Curve<int> x = new();
			x.Schedule(10, null, 110);
			x.Schedule(20, null, 120);
			x.Schedule(30, null, 130);
			x.Process(1);
			
			AssertThat(x.LowerBound(0)).IsNull();
			AssertThat(x.LowerBound(10)).IsEqual(((Downflux.Lib.Snapshot<int>) new (10, 110)));
			AssertThat(x.LowerBound(15)).IsEqual(((Downflux.Lib.Snapshot<int>) new (10, 110)));
			AssertThat(x.LowerBound(35)).IsEqual(((Downflux.Lib.Snapshot<int>) new (30, 130)));
		}
		
		[TestCase]
		public void TestUpperBound() {
			Downflux.Lib.Curve<int> x = new();
			x.Schedule(10, null, 110);
			x.Schedule(20, null, 120);
			x.Schedule(30, null, 130);
			x.Process(1);
			
			AssertThat(x.UpperBound(0)).IsEqual(((Downflux.Lib.Snapshot<int>) new (10, 110)));
			AssertThat(x.UpperBound(10)).IsEqual(((Downflux.Lib.Snapshot<int>) new (10, 110)));
			AssertThat(x.UpperBound(15)).IsEqual(((Downflux.Lib.Snapshot<int>) new (20, 120)));
			AssertThat(x.UpperBound(35)).IsNull();
		}
		
		[TestCase]
		[RequireGodotRuntime]
		public void TestNull() {
		}
}
