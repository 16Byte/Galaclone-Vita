extends Node

export var camera_path : NodePath  # drag your Camera2D in the Inspector
export var enemy_scene : PackedScene

var bullets_in_scene : int = 0

var sceneCache

func _ready() -> void:
	print("Operating System is: " + OS.get_name())
	enemy_scene = load("res://Scenes/Enemies/BossEnemy.tscn")
	
	sceneCache = get_tree().current_scene
	_on_scene_changed()
	
func _process(_delta) -> void:
	if Input.is_action_just_released("quick_menu"):
		_spawn_enemies_randomly(rand_range(4.0, 16))
		
	if get_tree().current_scene.name == "TestScene":
		if Input.is_action_just_released("pause"):
# warning-ignore:return_value_discarded
			get_tree().change_scene("res://Scenes/MainMenu.tscn")
			
	if get_tree().current_scene != sceneCache:
		_on_scene_changed()
		sceneCache = get_tree().current_scene
		
	if bullets_in_scene < 0:
		bullets_in_scene = 0

func _spawn_enemies_randomly(amount) -> void:
	for _i in range(amount):
		randomize()
		var enemy = enemy_scene.instance()
		
		get_tree().get_root().add_child(enemy)
		
		#other parameters go here
		enemy.global_position = Vector2(PlayArea.get_spawn_x(), PlayArea.get_spawn_y())
		enemy.health = 2

func _on_scene_changed() -> void:
	if get_tree().current_scene.name == "MainMenu":
		AudioServer.set_bus_volume_db(2, -80)
	
	if get_tree().current_scene.name == "TestScene":
		#call_deferred("_spawn_enemies_randomly", rand_range(4.0, 16.0))
		AudioServer.set_bus_volume_db(2, -5)
