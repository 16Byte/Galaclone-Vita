extends Node

var bounds : Rect2
var _camera : Camera2D
var isReady : bool = false

func initialize(camera: Camera2D, viewport_rect: Rect2) -> void:
	_camera = camera
	var half_w = viewport_rect.size.x / (2.0 * camera.zoom.x)
	var half_h = viewport_rect.size.y / (2.0 * camera.zoom.y)
	bounds = Rect2(-half_w, -half_h, half_w * 2.0, half_h * 2.0)
	isReady = true
	
	if get_tree().current_scene.name == "MainMenu":
		var star_field = preload("res://Scripts/Starfield.gd").new()
		star_field.bounds = bounds  # default already matches
		star_field.position = bounds.get_center() + Vector2(0, -225)
		add_child(star_field)

func get_spawn_x() -> float:
	randomize()
	return rand_range(bounds.position.x + 16.0, bounds.end.x - 16.0)

func get_spawn_y() -> float:
	randomize()
	return rand_range(bounds.position.y - 150, bounds.get_center().y - 200)
	#return bounds.position.y - 150
	#return bounds.get_center().y - 200

func is_out_of_bounds(pos: Vector2) -> bool:
	# grow(left, top, right, bottom) — top needs way more runway for bullets
	return not bounds.grow_individual(32, 300, 32, 32).has_point(pos)

func get_bounds() -> Rect2:
	return bounds

func _ready() -> void:
# warning-ignore:return_value_discarded
	get_tree().get_root().connect("size_changed", self, "_on_resize")

func _on_resize() -> void:
	if _camera:
		initialize(_camera, get_tree().get_root().get_visible_rect())
