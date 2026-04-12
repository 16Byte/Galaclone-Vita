extends Label

func _process(delta) -> void:
	# in any script that has access to a Label node
	text = str(Engine.get_frames_per_second()) + " fps"
