extends KinematicBody2D

export var clamp_to_x : bool = false

enum Faction { PLAYER, ENEMY }
export(Faction) var faction = Faction.PLAYER

func _physics_process(_delta) -> void:
	if clamp_to_x:
		_apply_x_clamp()
	if PlayArea.is_out_of_bounds(global_position):
		on_exit_bounds()

func _apply_x_clamp() -> void:
	var gp = global_position
	gp.x = clamp(gp.x, PlayArea.bounds.position.x + 40.0, PlayArea.bounds.end.x - 40.0)
	global_position = gp

func on_exit_bounds() -> void:
	pass

# warning-ignore:unused_argument
func take_damage(amount: int) -> void:
	pass
