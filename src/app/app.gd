extends Control

const GameScreenScene := preload("res://scenes/game/game_screen.tscn")
const MainMenuScreenScene := preload("res://scenes/menu/main_menu_screen.tscn")
const EpisodeSelectScreenScene := preload("res://scenes/menu/episode_select_screen.tscn")
const RulesScreenScene := preload("res://scenes/menu/rules_screen.tscn")
const HighScoreScreenScene := preload("res://scenes/menu/high_score_screen.tscn")
const OptionsScreenScene := preload("res://scenes/menu/options_screen.tscn")
const CreditsScreenScene := preload("res://scenes/menu/credits_screen.tscn")
const AudioCueCatalogScript := preload("res://src/audio/krakout_audio_cue_catalog.gd")

var _current_screen: Node


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_show_main_menu()


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
	_set_screen(game)


func _show_rules() -> void:
	_play_music_context(AudioCueCatalogScript.CONTEXT_RULES)
	var screen := RulesScreenScene.instantiate()
	screen.back_requested.connect(_show_main_menu)
	_set_screen(screen)


func _show_high_score() -> void:
	_play_music_context(AudioCueCatalogScript.CONTEXT_HIGH_SCORE)
	var screen := HighScoreScreenScene.instantiate()
	screen.back_requested.connect(_show_main_menu)
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

	_current_screen = screen
	add_child(screen)


func _on_start_game_requested() -> void:
	_show_episode_select()


func _on_episode_selected(episode_slug: String, level_number: int) -> void:
	_show_game(episode_slug, level_number)


func _on_quit_requested() -> void:
	get_tree().quit()


func _play_music_context(context_name: String) -> void:
	var audio := get_node_or_null("/root/KrakoutAudio")
	if audio != null and audio.has_method("play_music_context"):
		audio.call("play_music_context", context_name)
