extends Node

export var camera_path : NodePath  # drag your Camera2D in the Inspector

func _ready() -> void:
	print("Operating System is: " + OS.get_name())
	
func _process(_delta) -> void:
	if OS.get_name() == "Windows" or OS.get_name() == "X11":
		if Input.is_action_just_released("pause"):
			get_tree().quit()
