extends Control
class_name GameScreen

signal return_to_menu_requested

const PlayfieldRendererScript := preload("res://src/playfield/playfield_renderer.gd")
const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")
const GameSessionScript := preload("res://src/gameplay/krakout_game_session.gd")
const RacketRendererScript := preload("res://src/render/racket_renderer.gd")
const BallRendererScript := preload("res://src/render/ball_renderer.gd")
const GameHudScript := preload("res://src/game/game_hud.gd")

@export var episode_slug := PlayfieldSpecScript.DEFAULT_EPISODE
@export var level_number := PlayfieldSpecScript.DEFAULT_LEVEL_NUMBER

@onready var playfield_renderer: PlayfieldRenderer = $PlayfieldRenderer

var gameplay_session
var racket_renderer
var ball_renderer
var hud_renderer
var _run_started := false


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_fit_to_baseline_viewport()
	_ensure_gameplay_nodes()
	_apply_level()


func _process(delta: float) -> void:
	if gameplay_session == null:
		return

	gameplay_session.update(delta)
	if gameplay_session.consume_board_changed() and playfield_renderer != null:
		playfield_renderer.refresh_board()

	if gameplay_session.state == GameSessionScript.STATE_LEVEL_COMPLETE:
		_advance_to_next_level()
		return

	_refresh_actor_renderers()
	_refresh_hud()


func _input(event: InputEvent) -> void:
	if gameplay_session == null:
		return

	if event is InputEventMouseMotion:
		gameplay_session.move_racket_to(event.position.y)
		_refresh_actor_renderers()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if gameplay_session.state == GameSessionScript.STATE_GAME_OVER:
				return_to_menu_requested.emit()
				get_viewport().set_input_as_handled()
				return
			gameplay_session.launch_ready_ball()
			_refresh_actor_renderers()
			_refresh_hud()


func start_game(selected_episode_slug: String, selected_level_number: int) -> void:
	episode_slug = selected_episode_slug
	level_number = max(1, selected_level_number)
	_run_started = false
	_apply_level()


func current_game_session():
	return gameplay_session


func current_hud():
	return hud_renderer


func move_racket_to(mouse_y: float) -> void:
	if gameplay_session == null:
		return
	gameplay_session.move_racket_to(mouse_y)
	_refresh_actor_renderers()


func launch_ready_ball() -> bool:
	if gameplay_session == null:
		return false
	var launched: bool = gameplay_session.launch_ready_ball()
	_refresh_actor_renderers()
	_refresh_hud()
	return launched


func _fit_to_baseline_viewport() -> void:
	custom_minimum_size = Vector2(PlayfieldSpecScript.VIEWPORT_SIZE)


func _apply_level() -> void:
	_ensure_gameplay_nodes()
	if playfield_renderer == null:
		return

	playfield_renderer.default_episode = episode_slug
	playfield_renderer.default_level_number = _source_level_number()

	var level: KrakoutLevelData = _load_level()
	if level != null:
		if _run_started:
			gameplay_session.advance_to_level(level, level_number)
		else:
			gameplay_session.start_run(level, level_number, int(gameplay_session.best_score))
			_run_started = true
		playfield_renderer.set_board_state(gameplay_session.board_state)
		_refresh_actor_renderers()
		_refresh_hud()


func _load_level() -> KrakoutLevelData:
	var levels := get_node_or_null("/root/KrakoutLevels")
	if levels == null or not levels.has_method("load_level"):
		return null

	if levels.has_method("load_wrapped_level"):
		return levels.call("load_wrapped_level", episode_slug, level_number)

	return levels.call("load_level", episode_slug, level_number)


func _ensure_gameplay_nodes() -> void:
	if gameplay_session == null:
		gameplay_session = GameSessionScript.new()

	if racket_renderer == null:
		racket_renderer = RacketRendererScript.new()
		racket_renderer.name = "RacketRenderer"
		add_child(racket_renderer)

	if ball_renderer == null:
		ball_renderer = BallRendererScript.new()
		ball_renderer.name = "BallRenderer"
		add_child(ball_renderer)

	if hud_renderer == null:
		hud_renderer = GameHudScript.new()
		hud_renderer.name = "GameHud"
		add_child(hud_renderer)

	racket_renderer.set_session(gameplay_session)
	ball_renderer.set_session(gameplay_session)
	hud_renderer.set_session(gameplay_session)


func _refresh_actor_renderers() -> void:
	if racket_renderer != null:
		racket_renderer.queue_redraw()
	if ball_renderer != null:
		ball_renderer.queue_redraw()


func _refresh_hud() -> void:
	if hud_renderer != null and hud_renderer.has_method("refresh"):
		hud_renderer.call("refresh")


func _advance_to_next_level() -> void:
	level_number += 1
	_apply_level()


func _source_level_number() -> int:
	var levels := get_node_or_null("/root/KrakoutLevels")
	if levels != null and levels.has_method("wrapped_level_number"):
		var wrapped_number := int(levels.call("wrapped_level_number", episode_slug, level_number))
		if wrapped_number > 0:
			return wrapped_number
	return level_number
