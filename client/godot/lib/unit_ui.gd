class_name DFUnitUIBase
extends Node2D

@export var sprite: Sprite2D
@export var selector: Sprite2D
@export var collider: DFUnitCollider


func select(select: bool):
	selector.visible = select

func _ready():
	selector.visible = false
