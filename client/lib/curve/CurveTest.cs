using GdUnit4;
using static GdUnit4.Assertions;

namespace GdUnit4.Tests;

[TestSuite]
public class CurveTest {
		[TestCase]
		public void IsEqual() {
			AssertThat(1).Equals(1);
		}
		
		[TestCase] 
		[RequireGodotRuntime] // ← Add this for Godot-dependent tests
		public void IsNotNull() {
				 AssertThat(new Godot.Node2D()).IsNotNull();
		}
}
