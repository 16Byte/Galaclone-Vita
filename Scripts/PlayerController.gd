extends "res://Scripts/Entity.gd"

export var SPEED = 700
var velocity = Vector2.ZERO

func _physics_process(_delta):
	velocity.x = Input.get_axis("move_left", "move_right") * SPEED
	velocity.y = 0.0

# warning-ignore:return_value_discarded
	move_and_slide(velocity)

