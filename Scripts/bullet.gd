extends "res://Scripts/Entity.gd"

export var SPEED : float = 2000.0
export var direction : int = -1  # -1 up (player), 1 down (enemy)
export var damping : float = 0.92 # lower = faster falloff

var current_speed : float

func _ready() -> void:
	current_speed = SPEED

func _physics_process(delta) -> void:
	._physics_process(delta)
	current_speed = max(current_speed * damping, 800.0) # 400.0 is the floor
	move_and_slide(Vector2(0, current_speed * direction))

func on_exit_bounds() -> void:
	print("culling projectile")
	queue_free()
