extends Control
class_name GameScreen

signal return_to_menu_requested
signal game_over_confirmed(score: int, level_number: int, episode_slug: String)

const PlayfieldRendererScript := preload("res://src/playfield/playfield_renderer.gd")
const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")
const GameSessionScript := preload("res://src/gameplay/krakout_game_session.gd")
const RacketRendererScript := preload("res://src/render/racket_renderer.gd")
const BallRendererScript := preload("res://src/render/ball_renderer.gd")
const BonusRendererScript := preload("res://src/render/bonus_renderer.gd")
const BulletRendererScript := preload("res://src/render/bullet_renderer.gd")
const MonsterRendererScript := preload("res://src/render/monster_renderer.gd")
const BeeRendererScript := preload("res://src/render/bee_renderer.gd")
const ImpactEffectRendererScript := preload("res://src/render/impact_effect_renderer.gd")
const GameHudScript := preload("res://src/game/game_hud.gd")

const ACTION_LAUNCH_BALL := "krakout_launch_ball"
const ACTION_FIRE_PADDLE := "krakout_fire_paddle"
const ACTION_USE_BONUS := "krakout_use_bonus"
const ACTION_TOGGLE_BONUS_STACK := "krakout_toggle_bonus_stack"
const ACTION_TOGGLE_BALL_TRACKS := "krakout_toggle_ball_tracks"
const ACTION_TOGGLE_FPS := "krakout_toggle_fps"
const ACTION_PAUSE := "krakout_pause"
const ACTION_TERMINATE_GAME := "krakout_terminate_game"
const ACTION_CYCLE_BACKGROUND := "krakout_cycle_background"
const EXIT_CONFIRMATION_TEXT := "Are You sure to leave\nthis board (Y / N)"


class HourglassCursorOverlay:
	extends Control

	const FRAME_SIZE := Vector2(100, 100)
	const FRAME_COUNT := 20
	const FRAME_SECONDS := 0.05

	var _clock_texture: Texture2D
	var _cursor_position := Vector2(320, 240)
	var _elapsed := 0.0
	var _frame_index := 0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		size = Vector2(640, 480)
		visible = false
		_clock_texture = _load_clock_texture()

	func set_hourglass_visible(is_visible: bool) -> void:
		visible = is_visible
		if is_visible:
			queue_redraw()

	func set_cursor_position(cursor_position: Vector2) -> void:
		_cursor_position = cursor_position
		if visible:
			queue_redraw()

	func advance(delta: float) -> void:
		if not visible:
			return
		_elapsed += delta
		while _elapsed >= FRAME_SECONDS:
			_elapsed -= FRAME_SECONDS
			_frame_index = (_frame_index + 1) % FRAME_COUNT
			queue_redraw()

	func is_cursor_visible() -> bool:
		return visible

	func current_frame_index() -> int:
		return _frame_index

	func _draw() -> void:
		if not visible or _clock_texture == null:
			return
		var destination := Rect2(_cursor_position - FRAME_SIZE * 0.5, FRAME_SIZE)
		var source := Rect2(Vector2(0, _frame_index * int(FRAME_SIZE.y)), FRAME_SIZE)
		draw_texture_rect_region(_clock_texture, destination, source)

	func _load_clock_texture() -> Texture2D:
		var assets := get_node_or_null("/root/KrakoutAssets")
		if assets == null or not assets.has_method("load_texture"):
			return null
		return assets.call("load_texture", "Clock") as Texture2D

@export var episode_slug := PlayfieldSpecScript.DEFAULT_EPISODE
@export var level_number := PlayfieldSpecScript.DEFAULT_LEVEL_NUMBER

@onready var playfield_renderer: PlayfieldRenderer = $PlayfieldRenderer

var gameplay_session
var racket_renderer
var ball_renderer
var bonus_renderer
var bullet_renderer
var monster_renderer
var bee_renderer
var impact_effect_renderer
var hud_renderer
var _run_started := false
var _bonus_stack_visible := true
var _ball_tracks_visible := true
var _fps_visible := false
var _background_movable := true
var _background_type := 2
var _paused := false
var _exit_confirmation_visible := false
var _hourglass_cursor: HourglassCursorOverlay
var _exit_confirmation_label: Label
var _fps_label: Label
var _fps_elapsed := 0.0
var _fps_frames := 0
var _fps_value := 0
var _previous_mouse_mode: int = Input.MOUSE_MODE_VISIBLE
var _owns_mouse_mode := false
var _system_cursor_hidden_for_game_map := false


func _enter_tree() -> void:
	_previous_mouse_mode = Input.get_mouse_mode()
	_owns_mouse_mode = true
	_hide_system_cursor_for_game_map()


func _exit_tree() -> void:
	if not _owns_mouse_mode:
		return
	Input.set_mouse_mode(_previous_mouse_mode)
	_system_cursor_hidden_for_game_map = false
	_owns_mouse_mode = false


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_fit_to_baseline_viewport()
	_ensure_gameplay_nodes()
	_load_presentation_settings()
	_apply_level()
	_apply_presentation_settings()


func _process(delta: float) -> void:
	_update_fps_overlay(delta)
	if _hourglass_cursor != null:
		_hourglass_cursor.advance(delta)
	if gameplay_session == null:
		return
	if _paused or _exit_confirmation_visible:
		_refresh_hud()
		return

	gameplay_session.update(delta)
	_update_held_shooting_paddle()
	_record_best_score()
	_play_pending_audio_events()
	if gameplay_session.consume_board_changed() and playfield_renderer != null:
		playfield_renderer.refresh_board()
	_refresh_playfield_effects()

	if gameplay_session.state == GameSessionScript.STATE_LEVEL_COMPLETE:
		_advance_to_next_level()
		return

	_refresh_actor_renderers()
	_refresh_hud()


func _input(event: InputEvent) -> void:
	if gameplay_session == null:
		return

	if event is InputEventMouseMotion:
		if _hourglass_cursor != null:
			_hourglass_cursor.set_cursor_position(event.position)
		if _paused or _exit_confirmation_visible:
			return
		gameplay_session.move_racket_to(event.position.y)
		_refresh_actor_renderers()
		return

	if _is_repeated_key_event(event):
		return

	if _exit_confirmation_visible:
		_handle_exit_confirmation_input(event)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(ACTION_TERMINATE_GAME):
		show_exit_confirmation()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(ACTION_TOGGLE_FPS):
		toggle_fps_visible()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(ACTION_TOGGLE_BONUS_STACK):
		toggle_bonus_stack_visible()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(ACTION_TOGGLE_BALL_TRACKS):
		toggle_ball_tracks_visible()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(ACTION_CYCLE_BACKGROUND):
		cycle_background_type()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(ACTION_PAUSE):
		toggle_pause()
		get_viewport().set_input_as_handled()
	elif _paused:
		return
	elif event.is_action_pressed(ACTION_FIRE_PADDLE):
		var fire_result: Dictionary = fire_shooting_paddle()
		if String(fire_result.get("status", "")) != "unarmed":
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed(ACTION_USE_BONUS):
		var bonus_result: Dictionary = activate_next_bonus()
		if String(bonus_result.get("status", "")) != "empty":
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed(ACTION_LAUNCH_BALL):
		if gameplay_session.state == GameSessionScript.STATE_GAME_OVER:
			game_over_confirmed.emit(int(gameplay_session.score), int(gameplay_session.display_level_number), episode_slug)
			get_viewport().set_input_as_handled()
			return
		launch_ready_ball()
		get_viewport().set_input_as_handled()


func start_game(selected_episode_slug: String, selected_level_number: int) -> void:
	episode_slug = selected_episode_slug
	level_number = max(1, selected_level_number)
	_run_started = false
	_paused = false
	_exit_confirmation_visible = false
	_apply_level()
	_apply_pause_overlay()


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
	_play_pending_audio_events()
	_refresh_actor_renderers()
	_refresh_hud()
	return launched


func activate_next_bonus() -> Dictionary:
	if gameplay_session == null:
		return {"status": "missing_session"}
	var result: Dictionary = gameplay_session.activate_next_bonus()
	_play_pending_audio_events()
	_refresh_playfield_effects()
	_refresh_actor_renderers()
	_refresh_hud()
	return result


func fire_shooting_paddle() -> Dictionary:
	if gameplay_session == null:
		return {"status": "missing_session"}
	var result: Dictionary = gameplay_session.fire_shooting_paddle()
	_play_pending_audio_events()
	_refresh_actor_renderers()
	_refresh_hud()
	return result


func _update_held_shooting_paddle() -> void:
	if not Input.is_action_pressed(ACTION_FIRE_PADDLE):
		return
	gameplay_session.fire_shooting_paddle()


func toggle_bonus_stack_visible() -> bool:
	set_bonus_stack_visible(not _bonus_stack_visible)
	return _bonus_stack_visible


func set_bonus_stack_visible(is_visible: bool) -> void:
	_bonus_stack_visible = is_visible
	var profile := _profile_service()
	if profile != null and profile.has_method("set_bonus_stack_visible"):
		profile.call("set_bonus_stack_visible", is_visible)
	_apply_presentation_settings()


func is_bonus_stack_visible() -> bool:
	return _bonus_stack_visible


func toggle_ball_tracks_visible() -> bool:
	set_ball_tracks_visible(not _ball_tracks_visible)
	return _ball_tracks_visible


func set_ball_tracks_visible(is_visible: bool) -> void:
	_ball_tracks_visible = is_visible
	var profile := _profile_service()
	if profile != null and profile.has_method("set_ball_tracks_visible"):
		profile.call("set_ball_tracks_visible", is_visible)
	_apply_presentation_settings()


func are_ball_tracks_visible() -> bool:
	return _ball_tracks_visible


func toggle_fps_visible() -> bool:
	set_fps_visible(not _fps_visible)
	return _fps_visible


func set_fps_visible(is_visible: bool) -> void:
	_fps_visible = is_visible
	var profile := _profile_service()
	if profile != null and profile.has_method("set_fps_visible"):
		profile.call("set_fps_visible", is_visible)
	_apply_presentation_settings()


func is_fps_visible() -> bool:
	return _fps_visible


func cycle_background_type() -> int:
	var next_type := (_background_type + 1) % PlayfieldRendererScript.BACKGROUND_TYPE_COUNT
	set_background_type(next_type)
	return _background_type


func set_background_type(type_id: int) -> void:
	_background_type = clampi(type_id, 0, PlayfieldRendererScript.BACKGROUND_TYPE_COUNT - 1)
	var profile := _profile_service()
	if profile != null and profile.has_method("set_background_type"):
		profile.call("set_background_type", _background_type)
	_apply_presentation_settings()


func current_background_type() -> int:
	return _background_type


func set_background_movable(is_movable: bool) -> void:
	_background_movable = is_movable
	var profile := _profile_service()
	if profile != null and profile.has_method("set_background_movable"):
		profile.call("set_background_movable", is_movable)
	_apply_presentation_settings()


func is_background_movable() -> bool:
	return _background_movable


func toggle_pause() -> bool:
	if gameplay_session != null and gameplay_session.state == GameSessionScript.STATE_GAME_OVER:
		return _paused
	if _exit_confirmation_visible:
		return _paused
	_paused = not _paused
	_apply_pause_overlay()
	return _paused


func is_game_paused() -> bool:
	return _paused


func show_exit_confirmation() -> void:
	if gameplay_session != null and gameplay_session.state == GameSessionScript.STATE_GAME_OVER:
		return
	_exit_confirmation_visible = true
	_apply_pause_overlay()


func is_exit_confirmation_visible() -> bool:
	return _exit_confirmation_visible


func is_system_cursor_hidden() -> bool:
	return _system_cursor_hidden_for_game_map


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
			var starting_best_score: int = maxi(int(gameplay_session.best_score), _profile_best_score())
			gameplay_session.start_run(level, level_number, starting_best_score)
			_run_started = true
		gameplay_session.start_level_ready_sequence(true)
		playfield_renderer.set_board_state(gameplay_session.board_state)
		_refresh_playfield_effects()
		_refresh_actor_renderers()
		_refresh_hud()
		_play_pending_audio_events()


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

	if bonus_renderer == null:
		bonus_renderer = BonusRendererScript.new()
		bonus_renderer.name = "BonusRenderer"
		add_child(bonus_renderer)

	if bullet_renderer == null:
		bullet_renderer = BulletRendererScript.new()
		bullet_renderer.name = "BulletRenderer"
		add_child(bullet_renderer)

	if monster_renderer == null:
		monster_renderer = MonsterRendererScript.new()
		monster_renderer.name = "MonsterRenderer"
		add_child(monster_renderer)

	if bee_renderer == null:
		bee_renderer = BeeRendererScript.new()
		bee_renderer.name = "BeeRenderer"
		add_child(bee_renderer)

	if impact_effect_renderer == null:
		impact_effect_renderer = ImpactEffectRendererScript.new()
		impact_effect_renderer.name = "ImpactEffectRenderer"
		add_child(impact_effect_renderer)

	if hud_renderer == null:
		hud_renderer = GameHudScript.new()
		hud_renderer.name = "GameHud"
		add_child(hud_renderer)

	racket_renderer.set_session(gameplay_session)
	ball_renderer.set_session(gameplay_session)
	bonus_renderer.set_session(gameplay_session)
	bullet_renderer.set_session(gameplay_session)
	monster_renderer.set_session(gameplay_session)
	bee_renderer.set_session(gameplay_session)
	impact_effect_renderer.set_session(gameplay_session)
	hud_renderer.set_session(gameplay_session)
	_ensure_overlay_nodes()
	_apply_presentation_settings()


func _refresh_actor_renderers() -> void:
	if racket_renderer != null:
		racket_renderer.queue_redraw()
	if ball_renderer != null:
		ball_renderer.queue_redraw()
	if bonus_renderer != null:
		bonus_renderer.queue_redraw()
	if bullet_renderer != null:
		bullet_renderer.queue_redraw()
	if monster_renderer != null:
		monster_renderer.queue_redraw()
	if bee_renderer != null:
		bee_renderer.queue_redraw()
	if impact_effect_renderer != null:
		impact_effect_renderer.queue_redraw()


func _refresh_hud() -> void:
	if hud_renderer != null and hud_renderer.has_method("refresh"):
		hud_renderer.call("refresh")


func _profile_best_score() -> int:
	var profile := _profile_service()
	if profile == null or not profile.has_method("best_score"):
		return 0

	return maxi(0, int(profile.call("best_score")))


func _record_best_score() -> void:
	if gameplay_session == null:
		return

	var profile := _profile_service()
	if profile == null or not profile.has_method("record_score"):
		return

	profile.call("record_score", int(gameplay_session.best_score))


func _profile_service() -> Node:
	return get_node_or_null("/root/KrakoutProfile")


func _load_presentation_settings() -> void:
	var profile := _profile_service()
	if profile == null:
		return
	if profile.has_method("bonus_stack_visible"):
		_bonus_stack_visible = bool(profile.call("bonus_stack_visible"))
	if profile.has_method("ball_tracks_visible"):
		_ball_tracks_visible = bool(profile.call("ball_tracks_visible"))
	if profile.has_method("fps_visible"):
		_fps_visible = bool(profile.call("fps_visible"))
	if profile.has_method("background_movable"):
		_background_movable = bool(profile.call("background_movable"))
	if profile.has_method("background_type"):
		_background_type = clampi(int(profile.call("background_type")), 0, PlayfieldRendererScript.BACKGROUND_TYPE_COUNT - 1)


func _apply_presentation_settings() -> void:
	if bonus_renderer != null and bonus_renderer.has_method("set_stack_visible"):
		bonus_renderer.call("set_stack_visible", _bonus_stack_visible)
	if ball_renderer != null and ball_renderer.has_method("set_tracks_visible"):
		ball_renderer.call("set_tracks_visible", _ball_tracks_visible)
	if playfield_renderer != null:
		if playfield_renderer.has_method("set_background_type"):
			playfield_renderer.call("set_background_type", _background_type)
		if playfield_renderer.has_method("set_background_movable"):
			playfield_renderer.call("set_background_movable", _background_movable)
	if _fps_label != null:
		_fps_label.visible = _fps_visible
	_apply_pause_overlay()


func _refresh_playfield_effects() -> void:
	if playfield_renderer == null or gameplay_session == null:
		return
	if playfield_renderer.has_method("set_back_wall_active") and gameplay_session.has_method("is_back_wall_active"):
		playfield_renderer.call("set_back_wall_active", gameplay_session.call("is_back_wall_active"))


func _play_pending_audio_events() -> void:
	if gameplay_session == null or not gameplay_session.has_method("pop_audio_events"):
		return

	var events: Array = gameplay_session.call("pop_audio_events")
	if events.is_empty():
		return

	var audio := get_node_or_null("/root/KrakoutAudio")
	if audio == null or not audio.has_method("play_sfx_event"):
		return

	for event_name: Variant in events:
		audio.call("play_sfx_event", String(event_name))


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


func _ensure_overlay_nodes() -> void:
	if _hourglass_cursor == null:
		_hourglass_cursor = HourglassCursorOverlay.new()
		_hourglass_cursor.name = "HourglassCursorOverlay"
		add_child(_hourglass_cursor)

	if _exit_confirmation_label == null:
		_exit_confirmation_label = Label.new()
		_exit_confirmation_label.name = "ExitConfirmationPrompt"
		_exit_confirmation_label.position = Vector2(0, 198)
		_exit_confirmation_label.size = Vector2(640, 84)
		_exit_confirmation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_exit_confirmation_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_exit_confirmation_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_exit_confirmation_label.add_theme_color_override("font_color", Color.WHITE)
		_exit_confirmation_label.add_theme_font_size_override("font_size", 22)
		_exit_confirmation_label.text = EXIT_CONFIRMATION_TEXT
		_exit_confirmation_label.visible = false
		add_child(_exit_confirmation_label)

	if _fps_label == null:
		_fps_label = Label.new()
		_fps_label.name = "FpsOverlay"
		_fps_label.position = Vector2(8, 40)
		_fps_label.size = Vector2(120, 22)
		_fps_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		_fps_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_fps_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_fps_label.add_theme_color_override("font_color", Color.WHITE)
		_fps_label.add_theme_font_size_override("font_size", 14)
		_fps_label.visible = _fps_visible
		add_child(_fps_label)


func _apply_pause_overlay() -> void:
	_hide_system_cursor_for_game_map()
	if _hourglass_cursor != null:
		if _paused:
			_hourglass_cursor.set_cursor_position(get_viewport().get_mouse_position())
		_hourglass_cursor.set_hourglass_visible(_paused)
	if _exit_confirmation_label != null:
		_exit_confirmation_label.visible = _exit_confirmation_visible


func _hide_system_cursor_for_game_map() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_system_cursor_hidden_for_game_map = true


func _handle_exit_confirmation_input(event: InputEvent) -> void:
	if event.is_action_pressed(ACTION_TERMINATE_GAME):
		_cancel_exit_confirmation()
		return

	var key_event := event as InputEventKey
	if key_event == null or not key_event.pressed:
		return

	match key_event.keycode:
		KEY_Y:
			_confirm_exit_to_game_over_summary()
		KEY_N:
			_cancel_exit_confirmation()


func _confirm_exit_to_game_over_summary() -> void:
	_exit_confirmation_visible = false
	_paused = false
	gameplay_session.state = GameSessionScript.STATE_GAME_OVER
	_apply_pause_overlay()
	_refresh_hud()


func _cancel_exit_confirmation() -> void:
	_exit_confirmation_visible = false
	_apply_pause_overlay()


func _update_fps_overlay(delta: float) -> void:
	if not _fps_visible or _fps_label == null:
		return
	_fps_elapsed += delta
	_fps_frames += 1
	if _fps_elapsed >= 0.25:
		_fps_value = int(round(float(_fps_frames) / _fps_elapsed))
		_fps_elapsed = 0.0
		_fps_frames = 0
	_fps_label.text = "Fps: %d" % _fps_value


func _is_repeated_key_event(event: InputEvent) -> bool:
	var key_event := event as InputEventKey
	return key_event != null and key_event.echo
