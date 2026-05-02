extends Control

const GameScreenScene := preload("res://scenes/game/game_screen.tscn")
const MainMenuScreenScene := preload("res://scenes/menu/main_menu_screen.tscn")
const EpisodeSelectScreenScene := preload("res://scenes/menu/episode_select_screen.tscn")

var _current_screen: Node


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_show_main_menu()


func _show_main_menu() -> void:
	var menu := MainMenuScreenScene.instantiate()
	menu.start_game_requested.connect(_on_start_game_requested)
	menu.quit_requested.connect(_on_quit_requested)
	_set_screen(menu)


func _show_episode_select() -> void:
	var episode_select := EpisodeSelectScreenScene.instantiate()
	episode_select.episode_selected.connect(_on_episode_selected)
	episode_select.back_requested.connect(_show_main_menu)
	_set_screen(episode_select)


func _show_game(episode_slug: String, level_number: int) -> void:
	var game := GameScreenScene.instantiate()
	game.start_game(episode_slug, level_number)
	game.return_to_menu_requested.connect(_show_main_menu)
	_set_screen(game)


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
