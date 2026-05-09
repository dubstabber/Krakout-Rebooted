extends Control

const GameScreenScene := preload("res://scenes/game/game_screen.tscn")
const MainMenuScreenScene := preload("res://scenes/menu/main_menu_screen.tscn")
const EpisodeSelectScreenScene := preload("res://scenes/menu/episode_select_screen.tscn")
const RulesScreenScene := preload("res://scenes/menu/rules_screen.tscn")
const HighScoreScreenScene := preload("res://scenes/menu/high_score_screen.tscn")
const NameEntryScreenScene := preload("res://scenes/menu/name_entry_screen.tscn")
const OptionsScreenScene := preload("res://scenes/menu/options_screen.tscn")
const CreditsScreenScene := preload("res://scenes/menu/credits_screen.tscn")
const AudioCueCatalogScript := preload("res://src/audio/krakout_audio_cue_catalog.gd")
const CursorOverlayScript := preload("res://src/app/krakout_cursor_overlay.gd")

var _current_screen: Node
var _cursor_overlay: Control
var _previous_mouse_mode: int = Input.MOUSE_MODE_VISIBLE
var _owns_mouse_mode := false
var _system_cursor_hidden_for_menu := false
var _fullscreen_enabled := false
var _last_high_score_highlight_entry: Dictionary = {}


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_previous_mouse_mode = Input.get_mouse_mode()
	_owns_mouse_mode = true
	_ensure_cursor_overlay()
	_apply_presentation_settings_from_profile()
	_show_main_menu()


func _exit_tree() -> void:
	if not _owns_mouse_mode:
		return
	Input.set_mouse_mode(_previous_mouse_mode)
	_system_cursor_hidden_for_menu = false
	_owns_mouse_mode = false


func _show_main_menu() -> void:
	_play_music_context(AudioCueCatalogScript.CONTEXT_MAIN_MENU)
	var menu := MainMenuScreenScene.instantiate()
	menu.start_game_requested.connect(_on_start_game_requested)
	menu.rules_requested.connect(_show_rules)
	menu.high_score_requested.connect(_show_high_score)
	menu.options_requested.connect(_show_options)
	menu.credits_requested.connect(_show_credits)
	menu.quit_requested.connect(_on_quit_requested)
	_set_screen(menu)


func _show_episode_select() -> void:
	_play_music_context(AudioCueCatalogScript.CONTEXT_EPISODE_SELECT)
	var episode_select := EpisodeSelectScreenScene.instantiate()
	episode_select.episode_selected.connect(_on_episode_selected)
	episode_select.back_requested.connect(_show_main_menu)
	_set_screen(episode_select)


func _show_game(episode_slug: String, level_number: int) -> void:
	_play_music_context(AudioCueCatalogScript.CONTEXT_GAMEPLAY)
	var game := GameScreenScene.instantiate()
	game.start_game(episode_slug, level_number)
	game.return_to_menu_requested.connect(_show_main_menu)
	if game.has_signal("game_over_confirmed"):
		game.game_over_confirmed.connect(_on_game_over_confirmed)
	_set_screen(game)


func _show_rules() -> void:
	_play_music_context(AudioCueCatalogScript.CONTEXT_RULES)
	var screen := RulesScreenScene.instantiate()
	screen.back_requested.connect(_show_main_menu)
	_set_screen(screen)


func _show_high_score(highlight_entry: Dictionary = {}) -> void:
	_play_music_context(AudioCueCatalogScript.CONTEXT_HIGH_SCORE)
	if not highlight_entry.is_empty():
		_last_high_score_highlight_entry = highlight_entry.duplicate()
	var screen := HighScoreScreenScene.instantiate()
	if not _last_high_score_highlight_entry.is_empty() and screen.has_method("configure_highlight_entry"):
		screen.call("configure_highlight_entry", _last_high_score_highlight_entry)
	screen.back_requested.connect(_show_main_menu)
	_set_screen(screen)


func _show_name_entry(score: int, reached_level: int, episode_slug: String) -> void:
	_play_music_context(AudioCueCatalogScript.CONTEXT_NAME_ENTRY)
	var screen := NameEntryScreenScene.instantiate()
	screen.configure(score, reached_level, episode_slug, _episode_title_for_slug(episode_slug))
	screen.score_submitted.connect(_on_score_submitted)
	screen.cancel_requested.connect(_show_main_menu)
	_set_screen(screen)


func _show_options() -> void:
	_play_music_context(AudioCueCatalogScript.CONTEXT_OPTIONS)
	var screen := OptionsScreenScene.instantiate()
	screen.back_requested.connect(_show_main_menu)
	_set_screen(screen)


func _show_credits() -> void:
	_play_music_context(AudioCueCatalogScript.CONTEXT_CREDITS)
	var screen := CreditsScreenScene.instantiate()
	screen.back_requested.connect(_show_main_menu)
	_set_screen(screen)


func _set_screen(screen: Node) -> void:
	if _current_screen != null:
		_current_screen.queue_free()

	var is_game_screen := screen is GameScreen
	_set_original_cursor_active(not is_game_screen)

	_current_screen = screen
	add_child(screen)
	_raise_cursor_overlay()


func _on_start_game_requested() -> void:
	_show_episode_select()


func _on_episode_selected(episode_slug: String, level_number: int) -> void:
	_show_game(episode_slug, level_number)


func _on_game_over_confirmed(score: int, reached_level: int, episode_slug: String) -> void:
	var profile := _profile_service()
	if profile != null and profile.has_method("would_enter_high_score") and bool(profile.call("would_enter_high_score", score)):
		_show_name_entry(score, reached_level, episode_slug)
	else:
		_show_main_menu()


func _on_score_submitted(player_name: String, score: int, reached_level: int, episode_slug: String) -> void:
	var profile := _profile_service()
	if profile != null and profile.has_method("submit_high_score"):
		profile.call("submit_high_score", player_name, score, reached_level, episode_slug)
	_last_high_score_highlight_entry = {
		"name": player_name,
		"score": score,
		"level": reached_level,
		"episode": episode_slug,
	}
	_show_high_score()


func _on_quit_requested() -> void:
	get_tree().quit()


func is_original_cursor_active() -> bool:
	return _cursor_overlay != null and bool(_cursor_overlay.call("is_cursor_active"))


func is_system_cursor_hidden_for_menu() -> bool:
	return _system_cursor_hidden_for_menu


func is_fullscreen_enabled() -> bool:
	return _fullscreen_enabled


func set_fullscreen_enabled(is_enabled: bool) -> void:
	var profile := _profile_service()
	if profile != null and profile.has_method("set_fullscreen_enabled"):
		profile.call("set_fullscreen_enabled", is_enabled)
	apply_fullscreen_enabled(is_enabled)


func toggle_fullscreen_enabled() -> bool:
	set_fullscreen_enabled(not _fullscreen_enabled)
	return _fullscreen_enabled


func apply_fullscreen_enabled(is_enabled: bool) -> void:
	_fullscreen_enabled = is_enabled
	if DisplayServer.get_name() == "headless":
		return

	var window := get_window()
	if window == null:
		return

	window.mode = Window.MODE_FULLSCREEN if is_enabled else Window.MODE_WINDOWED


func _play_music_context(context_name: String) -> void:
	var audio := get_node_or_null("/root/KrakoutAudio")
	if audio != null and audio.has_method("play_music_context"):
		audio.call("play_music_context", context_name)


func _ensure_cursor_overlay() -> void:
	if _cursor_overlay != null:
		return
	_cursor_overlay = CursorOverlayScript.new()
	_cursor_overlay.name = "KrakoutCursorOverlay"
	add_child(_cursor_overlay)


func _raise_cursor_overlay() -> void:
	_ensure_cursor_overlay()
	move_child(_cursor_overlay, get_child_count() - 1)


func _set_original_cursor_active(is_active: bool) -> void:
	_ensure_cursor_overlay()
	if is_active:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		_system_cursor_hidden_for_menu = true
	else:
		_system_cursor_hidden_for_menu = false
	_cursor_overlay.set_cursor_active(is_active)


func _profile_service() -> Node:
	return get_node_or_null("/root/KrakoutProfile")


func _apply_presentation_settings_from_profile() -> void:
	var profile := _profile_service()
	if profile == null or not profile.has_method("fullscreen_enabled"):
		apply_fullscreen_enabled(false)
		return

	apply_fullscreen_enabled(bool(profile.call("fullscreen_enabled")))


func _episode_title_for_slug(episode_slug: String) -> String:
	var levels := get_node_or_null("/root/KrakoutLevels")
	if levels == null or not levels.has_method("episode_summaries"):
		return episode_slug

	for summary: Dictionary in levels.call("episode_summaries"):
		if String(summary.get("slug", "")) == episode_slug:
			return String(summary.get("title", episode_slug))
	return episode_slug
