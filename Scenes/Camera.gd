extends Camera2D

func _ready() -> void:
	PlayArea.initialize(self, get_tree().get_root().get_visible_rect())
