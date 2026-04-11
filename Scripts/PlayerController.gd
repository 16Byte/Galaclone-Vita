extends KinematicBody2D

export var SPEED = 700

var velocity = Vector2.ZERO

func _physics_process(_delta):
	velocity.x = Input.get_axis("move_left", "move_right")
	
	velocity = velocity.normalized() * SPEED
	
# warning-ignore:return_value_discarded
	move_and_slide(velocity)
