extends "res://Scripts/Entity.gd"

export var SPEED : float = 700.0
export var bullet_scene : PackedScene
var velocity = Vector2.ZERO

func _physics_process(delta) -> void:
	._physics_process(delta)
	velocity.x = Input.get_axis("move_left", "move_right") * SPEED
	velocity.y = 0.0
	move_and_slide(velocity)

	if Input.is_action_just_pressed("shoot"):
		_shoot()

func _shoot() -> void:
	var bullet = bullet_scene.instance()
	bullet.direction = -1
	bullet.global_position = global_position + Vector2(2.5, 0)
	get_tree().get_root().add_child(bullet)
