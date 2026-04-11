extends Node

var bounds : Rect2
var _camera : Camera2D  # store ref since get_camera_2d() doesn't exist in 3.x

func initialize(camera: Camera2D, viewport_rect: Rect2) -> void:
	_camera = camera
	var half_w = viewport_rect.size.x / (2.0 * camera.zoom.x)
	var half_h = viewport_rect.size.y / (2.0 * camera.zoom.y)
	# Don't use camera.global_position — get_visible_rect() is already in
	# screen-space starting at (0,0), so the world center IS the origin
	bounds = Rect2(-half_w, -half_h, half_w * 2.0, half_h * 2.0)

func get_spawn_x() -> float:
	return rand_range(bounds.position.x + 16.0, bounds.end.x - 16.0)  # was randf_range()

func get_spawn_y() -> float:
	return bounds.position.y - 32.0

func is_out_of_bounds(pos: Vector2) -> bool:
	return not bounds.grow(32.0).has_point(pos)

func get_bounds() -> Rect2:
	return bounds

func _ready() -> void:
	get_tree().get_root().connect("size_changed", self, "_on_resize")  # old signal syntax

func _on_resize() -> void:
	if _camera:
		initialize(_camera, get_tree().get_root().get_visible_rect())
