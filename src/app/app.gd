extends Control

const GameScreenScene := preload("res://scenes/game/game_screen.tscn")
const MainMenuScreenScene := preload("res://scenes/menu/main_menu_screen.tscn")

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


func _show_game() -> void:
	_set_screen(GameScreenScene.instantiate())


func _set_screen(screen: Node) -> void:
	if _current_screen != null:
		_current_screen.queue_free()

	_current_screen = screen
	add_child(screen)


func _on_start_game_requested() -> void:
	_show_game()


func _on_quit_requested() -> void:
	get_tree().quit()
