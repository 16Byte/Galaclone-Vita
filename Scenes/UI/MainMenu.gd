extends CanvasLayer

# ── Menu Definition ──────────────────────────────────────────────
# Each menu page is an Array of Dictionaries:
#   { "label": String, "action": String }
# "action" is either:
#   - A method name on this script (called on confirm)
#   - "push:<page_key>" to push a sub-menu onto the stack

var menu_pages := {
	"mode_select": [
		{ "label": "CLASSIC", "action": "push:classic_select" },
		{ "label": "CO-OP",   "action": "start_coop" },
	],
	"classic_select": [
		{ "label": "1 PLAYER", "action": "start_classic_1p" },
		{ "label": "2 PLAYER", "action": "start_classic_2p" },
	],
}

# ── Config ───────────────────────────────────────────────────────
export var cursor_text     := "> "     # Prefix for the selected item
export var item_spacing    := 36       # Vertical pixels between menu items
export var menu_y_offset   := 60.0     # How far below center the menu items start
export var blink_speed     := 0.6      # "PRESS START" blink interval in seconds
export var logo_y_offset   := -120.0   # Logo position relative to viewport center

# ── State ────────────────────────────────────────────────────────
var _stack       := []   # Stack of { "page": String, "index": int }
var _cursor      := 0
var _on_title    := true  # True = showing "PRESS START" splash
var _blink_timer := 0.0
var _blink_on    := true

# ── Node References (created in _ready) ──────────────────────────
var _logo_rect: TextureRect
var _press_start_label: Label
var _items_container: Control
var _item_labels := []


func _ready() -> void:
	layer = 10  # Render above everything

	# ── Root container: full-screen, centered ────────────────────
	var root := CenterContainer.new()
	root.anchor_right  = 1.0
	root.anchor_bottom = 1.0
	root.mouse_filter  = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	# Inner VBox for vertical layout (logo → press start / menu items)
	var vbox := VBoxContainer.new()
	vbox.alignment = VBoxContainer.ALIGN_CENTER
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(vbox)

	# ── Logo ─────────────────────────────────────────────────────
	_logo_rect = TextureRect.new()
	_logo_rect.texture = load("res://Assets/Sprites/Galaclone Logo pxArt.png")
	_logo_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_logo_rect.expand = true
	# 1536x1024 original → scale to ~420x280 to fit the 960x544 viewport
	_logo_rect.rect_min_size = Vector2(420, 280)
	vbox.add_child(_logo_rect)

	# Spacer between logo and menu area
	var spacer := Control.new()
	spacer.rect_min_size = Vector2(0, 60)
	vbox.add_child(spacer)

	# ── "PRESS START" label ──────────────────────────────────────
	_press_start_label = Label.new()
	_press_start_label.text = "PRESS START"
	_press_start_label.align = Label.ALIGN_CENTER
	_press_start_label.add_font_override("font", _make_font(24))
	_press_start_label.add_color_override("font_color", Color.white)
	vbox.add_child(_press_start_label)

	# ── Items container (hidden until past title screen) ─────────
	_items_container = VBoxContainer.new()
	_items_container.alignment = VBoxContainer.ALIGN_CENTER
	_items_container.visible = false
	_items_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_items_container)


func _process(delta: float) -> void:
	if _on_title:
		_blink_timer += delta
		if _blink_timer >= blink_speed:
			_blink_timer = 0.0
			_blink_on = !_blink_on
			_press_start_label.visible = _blink_on


func _unhandled_input(event: InputEvent) -> void:
	# ── Title screen: any confirm input advances ─────────────────
	if _on_title:
		if _is_confirm(event):
			_on_title = false
			_press_start_label.visible = false
			_press_start_label.queue_free()
			_items_container.visible = true
			_push_page("mode_select")
			get_tree().set_input_as_handled()
		return

	# ── Menu navigation ──────────────────────────────────────────
	if event.is_action_pressed("ui_up"):
		_move_cursor(-1)
		get_tree().set_input_as_handled()

	elif event.is_action_pressed("ui_down"):
		_move_cursor(1)
		get_tree().set_input_as_handled()

	elif _is_confirm(event):
		_confirm_selection()
		get_tree().set_input_as_handled()

	elif _is_back(event):
		_pop_page()
		get_tree().set_input_as_handled()


# ── Stack Operations ─────────────────────────────────────────────

func _push_page(page_key: String) -> void:
	# Save current cursor position if we have a page
	if _stack.size() > 0:
		_stack.back()["index"] = _cursor

	_stack.append({ "page": page_key, "index": 0 })
	_cursor = 0
	_rebuild_items(page_key)


func _pop_page() -> void:
	if _stack.size() <= 1:
		# Back to title screen from root menu
		_on_title = true
		_items_container.visible = false
		_press_start_label = _rebuild_press_start()
		_stack.clear()
		return

	_stack.pop_back()
	var prev = _stack.back()
	_cursor = prev["index"]
	_rebuild_items(prev["page"])


func _confirm_selection() -> void:
	var page_key: String = _stack.back()["page"]
	var page: Array = menu_pages[page_key]
	var action: String = page[_cursor]["action"]

	if action.begins_with("push:"):
		var target := action.substr(5)  # strip "push:"
		_push_page(target)
	elif has_method(action):
		call(action)
	else:
		push_warning("MainMenu: No method found for action '%s'" % action)


# ── Display ──────────────────────────────────────────────────────

func _rebuild_items(page_key: String) -> void:
	# Clear old labels
	for child in _items_container.get_children():
		child.queue_free()
	_item_labels.clear()

	# Wait a frame for queue_free to process, then build new ones
	# (For immediate use, we just add new children — old ones will clean up)
	var page: Array = menu_pages[page_key]
	for i in range(page.size()):
		var lbl := Label.new()
		lbl.align = Label.ALIGN_CENTER
		lbl.add_font_override("font", _make_font(22))
		lbl.add_color_override("font_color", Color.white)
		_items_container.add_child(lbl)
		_item_labels.append(lbl)

	_update_labels()


func _update_labels() -> void:
	var page_key: String = _stack.back()["page"]
	var page: Array = menu_pages[page_key]

	for i in range(_item_labels.size()):
		var prefix := cursor_text if i == _cursor else "  "
		_item_labels[i].text = prefix + page[i]["label"]

		# Dim non-selected items
		var color := Color.white if i == _cursor else Color(0.45, 0.45, 0.45)
		_item_labels[i].add_color_override("font_color", color)


func _move_cursor(direction: int) -> void:
	var page_key: String = _stack.back()["page"]
	var page_size: int = menu_pages[page_key].size()
	_cursor = wrapi(_cursor + direction, 0, page_size)
	_update_labels()


func _rebuild_press_start() -> Label:
	# Re-create the press start label (if player backs out to title)
	var lbl := Label.new()
	lbl.text = "PRESS START"
	lbl.align = Label.ALIGN_CENTER
	lbl.add_font_override("font", _make_font(24))
	lbl.add_color_override("font_color", Color.white)
	# Insert before items_container
	var parent = _items_container.get_parent()
	parent.add_child_below_node(_items_container, lbl)
	parent.move_child(lbl, _items_container.get_index())
	_blink_timer = 0.0
	_blink_on = true
	return lbl


# ── Input Helpers ────────────────────────────────────────────────

func _is_confirm(event: InputEvent) -> bool:
	return (
		event.is_action_pressed("ui_accept") or
		event.is_action_pressed("ui_select")
	)


func _is_back(event: InputEvent) -> bool:
	return event.is_action_pressed("ui_cancel")


# ── Font ─────────────────────────────────────────────────────────

var _font_data: DynamicFontData = preload("res://Assets/Fonts/Emulogic-zrEw.ttf")

func _make_font(size: int) -> DynamicFont:
	var font := DynamicFont.new()
	font.font_data = _font_data
	font.size = size
	font.use_filter = false  # Keep it crispy for pixel art
	return font


# ── Game Start Callbacks ─────────────────────────────────────────
# Wire these up to your scene transitions.

func start_classic_1p() -> void:
	print("Starting Classic — 1 Player")
	get_tree().change_scene("res://Scenes/TestScene.tscn")
	GameManager._spawn_enemies_randomly(15)


func start_classic_2p() -> void:
	print("Starting Classic — 2 Player")
	get_tree().change_scene("res://Scenes/TestScene.tscn")
	GameManager._spawn_enemies_randomly(15)


func start_coop() -> void:
	print("Starting Co-op")
	# get_tree().change_scene("res://Scenes/CoopGame.tscn")
