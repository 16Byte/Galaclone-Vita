extends "res://Scripts/Entity.gd"

export var SPEED : float = 2000.0
export var direction : int = -1  # -1 up (player), 1 down (enemy)
export var damping : float = 0.92 # lower = faster falloff

var shooter_faction : int = Faction.PLAYER

var current_speed : float

func _ready() -> void:
	current_speed = SPEED

func _physics_process(delta) -> void:
	._physics_process(delta)
	current_speed = max(current_speed * damping, 800.0) # 400.0 is the floor
# warning-ignore:return_value_discarded
	move_and_slide(Vector2(0, current_speed * direction))

func on_exit_bounds() -> void:
	print("culling projectile")
	GameManager.bullets_in_scene -= 1
	queue_free()

func _on_Area2D_body_entered(body):
	if body.get("faction") == shooter_faction:
		return  # same team, ignore
	if body.has_method("take_damage"):
		GameManager.bullets_in_scene -= 1
		body.take_damage(1)
		queue_free()
		
