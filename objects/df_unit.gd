extends CharacterBody2D

## DFUnit is the base unit script for a DownFlux body.
##
## DFUnit collision boxes must be convex -- concave collision boxes will trigger
## environment collisions multiple times, which will cause errors.
class_name DFUnit

var df_unit: DFUnit3D = DFUnit3D.new()

const SPEED = 5

func _process(_delta):
	var p = df_unit.position2d(DFUnit3D.ProjectionMode.ISOMETRIC)
	var v = df_unit.velocity2d(DFUnit3D.ProjectionMode.ISOMETRIC)
	position.x = p.x
	position.y = p.y
	velocity.x = v.x
	velocity.y = v.y

func _physics_process(delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		df_unit.velocity = Vector3(
			direction.normalized().x,
			-direction.normalized().y,
			0,
		) * SPEED
	df_unit._physics_process(delta)

func maybe_set_z_layer(z_layer: int):
	print("Set z_layer: ", z_layer)
	z_index = z_layer * ZTransitionBase._MAP_Z_INDEX_BUFFER
