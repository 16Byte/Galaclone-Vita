extends Label

var show : bool = false

func _ready() -> void:
	if Global.run_mode == Global.RuntimeMode.Dev || Global.run_mode == Global.RuntimeMode.Debug:
		show = true
	elif Global.run_mode == Global.RuntimeMode.Release:
		text = ""

# warning-ignore:unused_argument
func _process(delta) -> void:
	if show:
		text = str(Engine.get_frames_per_second()) + " fps"
