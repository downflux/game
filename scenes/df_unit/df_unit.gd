extends CharacterBody2D

## DFUnit is the base unit script for a DownFlux body.
##
## DFUnit collision boxes must be convex -- concave collision boxes will trigger
## environment collisions multiple times, which will cause errors.
class_name DFUnit

var _uuid = preload("res://third_party/godot-uuid/uuid.gd")

@export var z_layer: int
var df_unit: DFUnit3D

signal proxy_ramp_entered(source_z_layer: int)
signal proxy_ramp_exited(source_z_layer: int)

var _l: Layer
var _id: String

func _ready():
    df_unit = DFUnit3D.new(position)
    print(df_unit.position)
    _id = _uuid.v4()

func _init():
    _l = Layer.new(z_layer)
    z_index = _l.get_z_index(Layer.RenderLayer.UNIT)

func id() -> String:
    return _id

const SPEED = 100

func _process(_delta):
    var p = df_unit.position2d(DFVector.Mode.ISOMETRIC)
    var v = df_unit.velocity2d(DFVector.Mode.ISOMETRIC)
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
    _l.set_z_layer(z_layer)
    z_index = _l.get_z_index(Layer.RenderLayer.UNIT)
    print(z_index)
