extends Node

class CombatController:
	var units: Array
	
	func select(units: Array):
		self.units = units
	
	func deselect():
		self.units = []
	
	func move(p: Vector2i):
		return
	
	func primary(p: Vector2i):
		return
	
	func secondary(p: Vector2i):
		return
	
	func ultimate(p: Vector2i):
		return
