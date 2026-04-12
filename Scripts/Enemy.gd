extends "res://Scripts/Entity.gd"

var health : int

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
		print("culling enemy")
		queue_free()
