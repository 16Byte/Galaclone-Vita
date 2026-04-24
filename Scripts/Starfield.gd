extends Node2D

# Classic Galaga-style twinkling starfield.
# Perf notes:
#   - Parallel Pool*Arrays keep per-star data tight (no Object overhead)
#   - Single _draw() pass, one draw_rect per *visible* star
#   - Stars that leave `bounds` wrap to the opposite edge (respawn)
#   - update() fires once per frame because stars always move
#   - Twinkle = per-star phase/period timer, ~50% duty cycle
#
# Integration:
#   - Add as the FIRST child of a CanvasLayer so it draws behind everything
#     (or put it on its own CanvasLayer with a lower `layer` value).
#   - Change `bounds` at runtime to match a smaller play area in-game.

export var bounds: Rect2       = Rect2(0, 0, 960, 544)
export var star_count: int     = 240
export var direction: Vector2  = Vector2(0, 1)   # unit vector; down by default

export(Array, Color) var colors := [
	Color(1.00, 1.00, 1.00),  # white
	Color(1.00, 0.35, 0.35),  # red
	Color(0.35, 1.00, 1.00),  # cyan
	Color(0.40, 0.55, 1.00),  # blue
	Color(1.00, 0.70, 0.25),  # orange
	Color(1.00, 0.40, 1.00),  # magenta
	Color(0.45, 1.00, 0.45),  # green
	Color(1.00, 1.00, 0.40),  # yellow
]

const LAYER_SPEEDS  := [18.0, 42.0, 75.0]   # px/sec per layer
const LAYER_WEIGHTS := [0.40, 0.35, 0.25]   # distribution; sums to 1.0
const STAR_SIZE     := Vector2(2, 2)
const TWINKLE_MIN   := 0.25
const TWINKLE_MAX   := 1.40

# Parallel arrays -- index i describes star i across all of them.
var _px: PoolRealArray
var _py: PoolRealArray
var _speed: PoolRealArray
var _color_idx: PoolIntArray
var _period: PoolRealArray
var _phase: PoolRealArray
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	z_index = -254
	z_as_relative = false
	_rng.randomize()
	respawn_all()


# -- Public API -----------------------------------------
# Re-seed every star. Safe to call after changing `bounds`, `star_count`, etc.
func respawn_all() -> void:
	_px.resize(star_count)
	_py.resize(star_count)
	_speed.resize(star_count)
	_color_idx.resize(star_count)
	_period.resize(star_count)
	_phase.resize(star_count)

	for i in star_count:
		_px[i]        = bounds.position.x + _rng.randf() * bounds.size.x
		_py[i]        = bounds.position.y + _rng.randf() * bounds.size.y
		_speed[i]     = _pick_speed()
		_color_idx[i] = _rng.randi_range(0, colors.size() - 1)
		_period[i]    = _rng.randf_range(TWINKLE_MIN, TWINKLE_MAX)
		_phase[i]     = _rng.randf() * _period[i]


# -- Tick -----------------------------------------------
func _process(delta: float) -> void:
	var left  := bounds.position.x
	var top   := bounds.position.y
	var right := left + bounds.size.x
	var bot   := top + bounds.size.y
	var dx    := direction.x * delta
	var dy    := direction.y * delta

	for i in star_count:
		var nx: float = _px[i] + dx * _speed[i]
		var ny: float = _py[i] + dy * _speed[i]

		# Y wrap -- respawn at opposite edge with fresh X for variety.
		if ny >= bot:
			ny = top
			nx = left + _rng.randf() * bounds.size.x
		elif ny < top:
			ny = bot - 1.0
			nx = left + _rng.randf() * bounds.size.x

		# X wrap (no-op when direction.x == 0).
		if nx >= right:
			nx = left
		elif nx < left:
			nx = right - 1.0

		_px[i] = nx
		_py[i] = ny

		# Advance twinkle phase.
		var p: float = _phase[i] + delta
		if p >= _period[i]:
			p -= _period[i]
		_phase[i] = p

	update()


# -- Draw -----------------------------------------------
func _draw() -> void:
	for i in star_count:
		# On during first half of phase, off during second -- simple binary twinkle.
		if _phase[i] < _period[i] * 0.5:
			draw_rect(
				Rect2(_px[i], _py[i], STAR_SIZE.x, STAR_SIZE.y),
				colors[_color_idx[i]],
				true
			)


# -- Helpers --------------------------------------------
func _pick_speed() -> float:
	var r: float = _rng.randf()
	var acc: float = 0.0
	for i in LAYER_SPEEDS.size():
		acc += LAYER_WEIGHTS[i]
		if r <= acc:
			return LAYER_SPEEDS[i]
	return LAYER_SPEEDS[LAYER_SPEEDS.size() - 1]
