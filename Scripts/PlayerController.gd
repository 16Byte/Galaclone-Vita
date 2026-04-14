extends "res://Scripts/Entity.gd"

export var SPEED : float = 700.0
export var bullet_scene : PackedScene
export var ai_mode : bool = false

var velocity = Vector2.ZERO

# AI state
var _ai_move_timer : float = 0.0
var _ai_move_dir : float = 0.0
var _ai_shoot_timer : float = 0.0

func _physics_process(delta) -> void:
	._physics_process(delta)
	if ai_mode:
		_run_ai_mode(delta)
	else:
		velocity.x = Input.get_axis("move_left", "move_right") * SPEED
		position.y = 0 #ship should never move up or down unless in animation mode for ship capture (future addition)
		if Input.is_action_just_pressed("shoot"):
			_shoot()
	
	move_and_slide(velocity)

func _run_ai_mode(delta) -> void:
	# Wandering movement
	_ai_move_timer -= delta
	if _ai_move_timer <= 0.0:
		_ai_move_dir = [-1.0, 0.0, 1.0][randi() % 3]
		_ai_move_timer = rand_range(0.4, 1.2)
	
	velocity.x = _ai_move_dir * SPEED
	velocity.y = 0.0
	
	# Random shooting
	_ai_shoot_timer -= delta
	if _ai_shoot_timer <= 0.0:
		_shoot()
		_ai_shoot_timer = rand_range(0.3, 0.9)

func _shoot() -> void:
	var bullet = bullet_scene.instance()
	bullet.direction = -1
	bullet.global_position = global_position + Vector2(2.5, 0)
	get_tree().get_root().add_child(bullet)
