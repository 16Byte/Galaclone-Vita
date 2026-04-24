extends "res://Scripts/Entity.gd"

onready var audio_player = $AudioStreamPlayer

var health : int

var _dying : bool = false

enum EnemyType { 
	Bee, Butterfly, Boss,
	Scorpion, Stingray, Galaxian,
	Dragonfly, Satellite, Starship,}

export(EnemyType) var enemy_type = EnemyType.Bee

func _ready() -> void:
	match enemy_type:
		EnemyType.Boss:
			health = 2
		_:
			health = 1

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		_dying = true
		hide()
		set_physics_process(false)
		$CollisionShape2D.set_deferred("disabled", true)
		remove_from_group("entities")
		audio_player.play()
		yield (audio_player, "finished")
		queue_free()
