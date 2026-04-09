using GdUnit4;
using static GdUnit4.Assertions;

namespace Downflux.Tests;

[TestSuite]
public class CurveTest {
		[TestCase(Iterations = 10)]
		public void BenchmarkGet() {
			Downflux.Lib.Curve<float> x = new();
			
			ulong n_points = 1000;
			ulong n_runs = 1000000;
			int server_tps = 10;
			ulong granularity = 1000;
			
			for (ulong i = 0; i < n_points; i++) {
				x.Schedule((ulong) i * granularity, i);
			}
			x.Flush();
			
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
		public void TestGetVector2() {
			Downflux.Lib.Curve<Godot.Vector2> x = new();
			x.Schedule(10, new(110, 110));
			x.Schedule(20, new(120, 120));
			x.Schedule(30, new(130, 130));
			x.Flush();
			
			AssertThat(x.Get(0)).IsNull();
			AssertThat(x.Get(10)).IsEqual(new Downflux.Lib.Snapshot<Godot.Vector2>(10, new(110, 110)));
			AssertThat(x.Get(15)).IsEqual(new Downflux.Lib.Snapshot<Godot.Vector2>(15, new(115, 115)));
			AssertThat(x.Get(35)).IsEqual(new Downflux.Lib.Snapshot<Godot.Vector2>(35, new(130, 130)));
		}
		
		[TestCase]
		public void TestGetUlong() {
			Downflux.Lib.Curve<ulong> x = new();
			x.Schedule(10, 110);
			x.Schedule(20, 120);
			x.Schedule(30, 130);
			x.Flush();
			
			AssertThat(x.Get(0)).IsNull();
			AssertThat(x.Get(10)).IsEqual(new Downflux.Lib.Snapshot<ulong>(10, 110));
			AssertThat(x.Get(15)).IsEqual(new Downflux.Lib.Snapshot<ulong>(15, 115));
			AssertThat(x.Get(35)).IsEqual(new Downflux.Lib.Snapshot<ulong>(35, 130));
		}
		
		[TestCase]
		public void TestGetInt() {
			Downflux.Lib.Curve<int> x = new();
			x.Schedule(10, 110);
			x.Schedule(20, 120);
			x.Schedule(30, 130);
			x.Flush();
			
			AssertThat(x.Get(0)).IsNull();
			AssertThat(x.Get(10)).IsEqual(new Downflux.Lib.Snapshot<int>(10, 110));
			AssertThat(x.Get(15)).IsEqual(new Downflux.Lib.Snapshot<int>(15, 115));
			AssertThat(x.Get(35)).IsEqual(new Downflux.Lib.Snapshot<int>(35, 130));
		}
		
		[TestCase]
		public void TestGetFloat() {
			Downflux.Lib.Curve<float> x = new();
			x.Schedule(10, 110);
			x.Schedule(20, 120);
			x.Schedule(30, 130);
			x.Flush();
			
			AssertThat(x.Get(0)).IsNull();
			AssertThat(x.Get(10)).IsEqual(new Downflux.Lib.Snapshot<float>(10, 110));
			AssertThat(x.Get(15)).IsEqual(new Downflux.Lib.Snapshot<float>(15, 115));
			AssertThat(x.Get(35)).IsEqual(new Downflux.Lib.Snapshot<float>(35, 130));
		}
		
		[TestCase]
		public void TestLowerBound() {
			Downflux.Lib.Curve<int> x = new();
			x.Schedule(10, 110);
			x.Schedule(20, 120);
			x.Schedule(30, 130);
			x.Flush();
			
			AssertThat(x.LowerBound(0)).IsNull();
			AssertThat(x.LowerBound(10)).IsEqual(new Downflux.Lib.Snapshot<int>(10, 110));
			AssertThat(x.LowerBound(15)).IsEqual(new Downflux.Lib.Snapshot<int>(10, 110));
			AssertThat(x.LowerBound(35)).IsEqual(new Downflux.Lib.Snapshot<int>(30, 130));
		}
		
		[TestCase]
		public void TestUpperBound() {
			Downflux.Lib.Curve<int> x = new();
			x.Schedule(10, 110);
			x.Schedule(20, 120);
			x.Schedule(30, 130);
			x.Flush();
			
			AssertThat(x.UpperBound(0)).IsEqual(new Downflux.Lib.Snapshot<int>(10, 110));
			AssertThat(x.UpperBound(10)).IsEqual(new Downflux.Lib.Snapshot<int>(10, 110));
			AssertThat(x.UpperBound(15)).IsEqual(new Downflux.Lib.Snapshot<int>(20, 120));
			AssertThat(x.UpperBound(35)).IsNull();
		}
		
		[TestCase]
		public void TestTrim() {
			var x = new Downflux.Lib.Curve<float>();
			x.Schedule(10, 110);
			x.Schedule(20, 120);
			x.Schedule(30, 130);
			x.Flush();
			
			x.Trim(10);
			x.Flush();
			
			AssertThat(x.Get(0)).IsNull();
			AssertThat(x.Get(15)).IsEqual(new Downflux.Lib.Snapshot<float>(15, 110));
		}
		
		[TestCase]
		public void TestMerge() {
			Downflux.Lib.Curve<float> x = new();
			x.Schedule(10, 110);
			x.Schedule(20, 120);
			x.Schedule(30, 130);
			x.Flush();
			
			x.Merge(
				25,
				new System.Collections.Generic.List<Downflux.Lib.Snapshot<float>>{
					new (30, 140),
					new (40, 150),
				});
			x.Flush();
			
			AssertThat(x.Get(0)).IsNull();
			AssertThat(x.Get(15)).IsEqual(new Downflux.Lib.Snapshot<float>(15, 115));
			AssertThat(x.Get(25)).IsEqual(new Downflux.Lib.Snapshot<float>(25, 120));
			AssertThat(x.Get(28)).IsEqual(new Downflux.Lib.Snapshot<float>(28, 132));
			AssertThat(x.Get(40)).IsEqual(new Downflux.Lib.Snapshot<float>(40, 150));
		}
		
		[TestCase]
		public void TestGetSlice() {
			Downflux.Lib.Curve<float> x = new();
			x.Schedule(10, 110);
			x.Schedule(20, 120);
			x.Schedule(30, 130);
			x.Flush();
			
			AssertThat(x.GetSlice((0, 1))).IsEqual(null);
			AssertThat(x.GetSlice((0, 10))).IsEqual(
				new System.Collections.Generic.List<Downflux.Lib.Snapshot<float>>{
					new(10, 110),
				});
			AssertThat(x.GetSlice((10, 10))).IsEqual(
				new System.Collections.Generic.List<Downflux.Lib.Snapshot<float>>{
					new(10, 110),
				});
			AssertThat(x.GetSlice((0, 11))).IsEqual(
				new System.Collections.Generic.List<Downflux.Lib.Snapshot<float>>{
					new(10, 110),
					new(11, 111),
				});
			AssertThat(x.GetSlice((10, 21))).IsEqual(
				new System.Collections.Generic.List<Downflux.Lib.Snapshot<float>>{
					new(10, 110),
					new(20, 120),
					new(21, 121),
				});
			AssertThat(x.GetSlice((10, 30))).IsEqual(
				new System.Collections.Generic.List<Downflux.Lib.Snapshot<float>>{
					new(10, 110),
					new(20, 120),
					new(30, 130),
				});
			AssertThat(x.GetSlice((31, 32))).IsEqual(null);
		}
		
		[TestCase]
		[RequireGodotRuntime]
		public void TestNull() {
		}
}
