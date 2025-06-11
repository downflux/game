class_name DFUnitUIBase
extends Node2D

@export var sprite: Sprite2D
@export var selector: Sprite2D
@export var collider: DFUnitCollider


func select(s: bool):
	selector.visible = s


func _ready():
	selector.visible = false
