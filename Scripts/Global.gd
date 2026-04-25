extends Node

enum RuntimeMode {
	Dev,
	Debug,
	Release,
}

var run_mode = RuntimeMode.Release

func _ready() -> void:
	match run_mode:
		RuntimeMode.Dev:
			print("Starting game in 'Dev' mode.")
		RuntimeMode.Debug:
			print("Starting game in 'Debug' mode.")
		RuntimeMode.Release:
			print("Starting game in 'Release' mode.")
	
