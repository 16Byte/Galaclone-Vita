extends CanvasLayer

# Simple, Vita-friendly main menu.
# Key perf wins vs the old version:
#   - ONE shared DynamicFont (not one per label) -- glyph atlas rasterized once
#   - No Control/Container tree -- everything drawn in a single _draw() pass on one Node2D
#   - Redraws only fire on state change (cursor move, blink, page change)
#   - _process disabled outside the title screen

onready var ui_sfx_player = $"../UI_SFX"

const VIEWPORT       := Vector2(960, 544)
const LOGO_SIZE      := Vector2(420, 280)
const LOGO_Y         := 40.0
const MENU_Y         := 360.0
const ITEM_SPACING   := 40.0
const BLINK_INTERVAL := 0.6

const FONT_DATA := preload("res://Assets/Fonts/Emulogic-zrEw.ttf")
#const LOGO_TEX  := preload("res://Assets/Sprites/Galaclone Logo pxArt.png")

enum Page { TITLE, MODE, CLASSIC }

const ITEMS := {
	Page.MODE:    ["CLASSIC", "CO-OP"],
	Page.CLASSIC: ["1 PLAYER", "2 PLAYER"],
}

var _page: int      = Page.TITLE
var _cursor: int    = 0
var _blink_on: bool = true
var _blink_t: float = 0.0

var _font: DynamicFont
var _canvas: Node2D


func _ready() -> void:
	layer = 10

	# One shared font for everything on the menu.
	_font = DynamicFont.new()
	_font.font_data  = FONT_DATA
	_font.size       = 22
	_font.use_filter = false
	
	#var star_field = preload("res://Scripts/Starfield.gd").new()
	#star_field.bounds = Rect2(0, 0, 960, 544)  # default already matches
	#add_child(star_field)

	# Single Node2D owns all drawing. No Controls, no containers.
	_canvas = Node2D.new()
# warning-ignore:return_value_discarded
	_canvas.connect("draw", self, "_on_draw")
	add_child(_canvas)
	
	GameManager.call_deferred("_spawn_enemies_randomly", 15)


func _process(delta: float) -> void:
	_blink_t += delta
	if _blink_t >= BLINK_INTERVAL:
		_blink_t -= BLINK_INTERVAL
		_blink_on = not _blink_on
		_canvas.update()


func _unhandled_input(event: InputEvent) -> void:
	if _page == Page.TITLE:
		if _is_confirm(event):
			_goto(Page.MODE)
			get_tree().set_input_as_handled()
		return

	if Input.is_action_just_pressed("ui_up"):
		_move(-1)
		get_tree().set_input_as_handled()
	elif Input.is_action_just_pressed("ui_down"):
		_move(1)
		get_tree().set_input_as_handled()
	elif _is_confirm(event):
		_confirm()
		get_tree().set_input_as_handled()
	elif Input.is_action_just_pressed("ui_cancel"):
		_back()
		get_tree().set_input_as_handled()


# -- Nav ------------------------------------------------
func _goto(page: int) -> void:
	_page = page
	_cursor = 0
	ui_sfx_player.play()
	set_process(page == Page.TITLE)  # only tick blink on title
	if page == Page.TITLE:
		_blink_on = true
		_blink_t  = 0.0
	_canvas.update()


func _back() -> void:
	match _page:
		Page.CLASSIC: _goto(Page.MODE)
		Page.MODE:    _goto(Page.TITLE)


func _move(dir: int) -> void:
	_cursor = wrapi(_cursor + dir, 0, ITEMS[_page].size())
	_canvas.update()


func _confirm() -> void:
	match _page:
		Page.MODE:
			if _cursor == 0: _goto(Page.CLASSIC)
			else:            start_coop()
		Page.CLASSIC:
			if _cursor == 0: start_classic_1p()
			else:            start_classic_2p()


# -- Draw -----------------------------------------------
func _on_draw() -> void:
# warning-ignore:unused_variable
	var logo_pos := Vector2((VIEWPORT.x - LOGO_SIZE.x) * 0.5, LOGO_Y)
	#_canvas.draw_texture_rect(LOGO_TEX, Rect2(logo_pos, LOGO_SIZE), false)

	if _page == Page.TITLE:
		if _blink_on:
			_draw_centered("PRESS START", MENU_Y, Color.white)
		return

	var items: Array = ITEMS[_page]
	for i in items.size():
		var selected: bool = (i == _cursor)
		var text: String   = ("> " if selected else "  ") + items[i]
		var col: Color     = Color.white if selected else Color(0.45, 0.45, 0.45)
		_draw_centered(text, MENU_Y + i * ITEM_SPACING, col)


func _draw_centered(text: String, y: float, color: Color) -> void:
	var w := _font.get_string_size(text).x
	_canvas.draw_string(_font, Vector2((VIEWPORT.x - w) * 0.5, y), text, color)


# -- Helpers --------------------------------------------
func _is_confirm(event: InputEvent) -> bool:
	return event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select")


# -- Game Start -----------------------------------------
func start_classic_1p() -> void:
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/TestScene.tscn")
	GameManager._spawn_enemies_randomly(15)


func start_classic_2p() -> void:
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/TestScene.tscn")
	GameManager._spawn_enemies_randomly(15)


func start_coop() -> void:
	# get_tree().change_scene("res://Scenes/CoopGame.tscn")
	pass
