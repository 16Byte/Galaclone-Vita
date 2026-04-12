extends Node

export var camera_path : NodePath  # drag your Camera2D in the Inspector
export var enemy_scene : PackedScene

func _ready() -> void:
	print("Operating System is: " + OS.get_name())
	enemy_scene = load("res://Scenes/Enemies/BossEnemy.tscn")
	#if PlayArea.isReady:
	call_deferred("_spawn_enemies_randomly", rand_range(4.0, 16.0))
	
func _process(_delta) -> void:
	if OS.get_name() == "Windows" or OS.get_name() == "X11":
		if Input.is_action_just_released("pause"):
			get_tree().quit()

func _spawn_enemies_randomly(amount) -> void:
	for _i in range(amount):
		randomize()
		var enemy = enemy_scene.instance()
		
		get_tree().get_root().add_child(enemy)
		
		#other parameters go here
		enemy.global_position = Vector2(PlayArea.get_spawn_x(), PlayArea.get_spawn_y())
		enemy.health = rand_range(1.0, 3.0)
