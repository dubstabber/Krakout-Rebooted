extends SceneTree

const AssetsScript := preload("res://src/autoloads/krakout_assets.gd")
const LevelsScript := preload("res://src/autoloads/krakout_levels.gd")
const LevelDataScript := preload("res://src/data/krakout_level_data.gd")
const LevelGridRendererScript := preload("res://src/render/level_grid_renderer.gd")
const BrickAtlasMappingScript := preload("res://src/render/brick_atlas_mapping.gd")
const GameplaySheetCatalogScript := preload("res://src/playfield/krakout_gameplay_sheet_catalog.gd")
const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")
const BrickSemanticsScript := preload("res://src/gameplay/krakout_brick_semantics.gd")
const BoardStateScript := preload("res://src/gameplay/krakout_board_state.gd")
const MainMenuScreenScene := preload("res://scenes/menu/main_menu_screen.tscn")
const EpisodeSelectScreenScene := preload("res://scenes/menu/episode_select_screen.tscn")
const GameScreenScene := preload("res://scenes/game/game_screen.tscn")
const AppScene := preload("res://scenes/app/app.tscn")

var _failures := 0
var _assets: Node
var _levels: Node


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	await process_frame

	_ensure_test_autoloads()

	_assert(_assets.reload(), "asset manifest reloads")
	_assert(_assets.texture_count() == 37, "expected 37 textures")
	_assert(_assets.sfx_count() == 25, "expected 25 sfx files")
	_assert(_assets.music_count() == 10, "expected 10 music files")
	_assert(_assets.level_count() == 441, "expected 441 levels")

	_assert(_assets.texture_path("Bricks") == "res://assets/krakout/textures/Bricks.png", "Bricks texture path is indexed")
	_assert(_assets.music_path("theme1") == "res://assets/krakout/audio/music/theme1.ogg", "theme1 music path is indexed")
	_assert(ResourceLoader.exists(_assets.texture_path("Bricks")), "Bricks texture is loadable")
	_assert(ResourceLoader.exists(_assets.music_path("theme1")), "theme1 music is loadable")

	var episode_slugs: Array = _assets.episode_slugs()
	_assert(episode_slugs.has("Default"), "Default episode is indexed")
	_assert(_assets.level_path("Default", 1) == "res://assets/krakout/levels/Default/level_001.json", "Default level 1 path is indexed")
	_validate_episode_catalog()

	var level = _load_level_from_path(_assets.level_path("Default", 1))
	_assert(level != null, "Default level 1 loads")
	if level != null:
		_assert(level.columns == LevelDataScript.COLUMNS, "Default level has 20 columns")
		_assert(level.rows_count == LevelDataScript.ROWS, "Default level has 13 rows")
		_assert(level.tile_at(0, 0) == 19, "Default level first raw tile is preserved")
		_assert(level.tile_at(19, 0) == 0, "Default level first row preserves empty board tail cells")
		_assert(level.level_tail_bytes.size() == LevelDataScript.LEVEL_TAIL_SIZE, "Default level preserves 50 tail bytes")
		_assert(level.level_tail_bytes[0] == 0, "Default level tail byte 0 is preserved")
		_assert(level.level_tail_bytes[14] == 5, "Default level tail non-zero data is preserved")
		_assert(level.tile_semantics == "unmapped", "Default level tile semantics stay unmapped")
		_assert(level.populated_tile_count() > 0, "Default level contains non-empty raw tiles")
		_validate_board_state(level)

	_validate_playfield_spec()
	_validate_brick_semantics()
	_validate_brick_atlas_mapping()
	_validate_level_grid_renderer_defaults()
	_validate_gameplay_sheet_catalog()
	_validate_manifest_paths()
	await _validate_menu_and_game_scenes()

	if _failures == 0:
		print("Krakout foundation tests passed.")
		quit(0)
	else:
		push_error("Krakout foundation tests failed: %d" % _failures)
		quit(1)


func _ensure_test_autoloads() -> void:
	_assets = root.get_node_or_null("KrakoutAssets")
	if _assets == null:
		_assets = AssetsScript.new()
		_assets.name = "KrakoutAssets"
		root.add_child(_assets)

	_levels = root.get_node_or_null("KrakoutLevels")
	if _levels == null:
		_levels = LevelsScript.new()
		_levels.name = "KrakoutLevels"
		root.add_child(_levels)


func _validate_manifest_paths() -> void:
	for texture_entry: Dictionary in _assets.manifest.get("textures", []):
		_assert(_is_runtime_path(texture_entry), "texture manifest path is runtime-safe")

	for sfx_entry: Dictionary in _assets.manifest.get("audio", {}).get("sfx", []):
		_assert(_is_runtime_path(sfx_entry), "sfx manifest path is runtime-safe")

	for music_entry: Dictionary in _assets.manifest.get("audio", {}).get("music", []):
		_assert(_is_runtime_path(music_entry), "music manifest path is runtime-safe")

	for level_entry: Dictionary in _assets.manifest.get("levels", []):
		_assert(_is_runtime_path(level_entry), "level manifest path is runtime-safe")


func _validate_episode_catalog() -> void:
	var episode_summaries: Array = _assets.episode_summaries()
	_assert(episode_summaries.size() == 17, "episode summary catalog exposes all extracted episodes")
	_assert(_levels.episode_summaries().size() == 17, "level autoload exposes episode summaries")

	var default_summary := _find_summary(episode_summaries, "Default")
	_assert(not default_summary.is_empty(), "Default episode summary exists")
	if not default_summary.is_empty():
		_assert(default_summary["title"] == "Default Episode", "Default summary preserves decoded episode title")
		_assert(default_summary["level_count"] == 14, "Default summary preserves level count")
		_assert(default_summary["first_level_number"] == 1, "Default summary exposes first level number")

	var abstraction_summary := _find_summary(episode_summaries, "Abstraction")
	_assert(not abstraction_summary.is_empty(), "Abstraction episode summary exists")
	if not abstraction_summary.is_empty():
		_assert(abstraction_summary["title"] == "Abstraction", "Abstraction summary preserves decoded episode title")
		_assert(abstraction_summary["level_count"] == 14, "Abstraction summary preserves level count")

	if episode_summaries.size() > 0:
		_assert(episode_summaries[0]["slug"] == "Abstraction", "episode summaries are sorted by decoded title")


func _validate_playfield_spec() -> void:
	_assert(PlayfieldSpecScript.VIEWPORT_SIZE == Vector2i(640, 480), "playfield viewport preserves original size")
	_assert(PlayfieldSpecScript.GRID_COLUMNS == LevelDataScript.COLUMNS, "playfield grid column count matches levels")
	_assert(PlayfieldSpecScript.GRID_ROWS == LevelDataScript.ROWS, "playfield grid row count matches levels")
	_assert(PlayfieldSpecScript.GRID_ORIGIN == Vector2(47, 63), "playfield grid origin matches IDA draw loop")
	_assert(PlayfieldSpecScript.BRICK_SIZE == Vector2(20, 30), "playfield brick size matches Bricks sheet cells")
	_assert(PlayfieldSpecScript.GRID_SIZE == Vector2(400, 390), "playfield grid size derives from 20x13 bricks")
	_assert(PlayfieldSpecScript.grid_rect() == Rect2(Vector2(47, 63), Vector2(400, 390)), "playfield grid rect is stable")
	_assert(PlayfieldSpecScript.brick_rect(19, 12) == Rect2(Vector2(427, 423), Vector2(20, 30)), "playfield brick rect maps final cell")


func _validate_brick_semantics() -> void:
	_assert(not BrickSemanticsScript.is_active_tile(0), "tile 0 is inactive")
	_assert(not BrickSemanticsScript.is_active_tile(162), "tile 162 starts inactive range")
	_assert(BrickSemanticsScript.is_active_tile(161), "tile 161 remains active")
	_assert(not BrickSemanticsScript.is_required_tile(8), "tile 8 is active but not completion-counting")
	_assert(not BrickSemanticsScript.is_required_tile(39), "tile 39 is active but not completion-counting")
	_assert(not BrickSemanticsScript.is_required_tile(40), "tile 40 is active but not completion-counting")
	_assert(not BrickSemanticsScript.is_required_tile(69), "tile 69 is active but not completion-counting")
	_assert(BrickSemanticsScript.is_required_tile(43), "tile 43 counts before chain explosion")
	_assert(BrickSemanticsScript.is_chain_explosion_tile(43), "tile 43 is a chain explosion tile")
	_assert(BrickSemanticsScript.is_chain_explosion_tile(68), "tile 68 is a chain explosion tile")


func _validate_board_state(default_level: KrakoutLevelData) -> void:
	var default_state = _board_state_from_level(default_level)
	_assert(default_state.columns == LevelDataScript.COLUMNS, "board state preserves column count")
	_assert(default_state.rows_count == LevelDataScript.ROWS, "board state preserves row count")
	_assert(default_state.active_tile_count == 143, "Default level 1 active tile count is IDA-backed")
	_assert(default_state.remaining_required_bricks == 143, "Default level 1 required brick count is IDA-backed")
	_assert(not default_state.is_complete(), "Default level 1 starts incomplete")

	var original_first_tile := default_level.tile_at(0, 0)
	_assert(default_state.clear_tile(0, 0), "board state clears a populated tile")
	_assert(default_state.tile_at(0, 0) == 0, "board state tile is mutable")
	_assert(default_state.remaining_required_bricks == 142, "clearing a required tile decrements completion count")
	_assert(default_level.tile_at(0, 0) == original_first_tile, "board state does not mutate source level data")

	var semantic_state = _board_state_from_level(_make_level_from_rows([[8, 39, 40, 69, 162, 0, 1]]))
	_assert(semantic_state.active_tile_count == 5, "board state counts active non-empty gameplay tiles")
	_assert(semantic_state.remaining_required_bricks == 1, "board state excludes proven non-required tile IDs")
	_assert(semantic_state.clear_tile(0, 0), "board state clears non-required active tile")
	_assert(semantic_state.remaining_required_bricks == 1, "clearing non-required active tile preserves completion count")
	_assert(semantic_state.clear_tile(6, 0), "board state clears required tile")
	_assert(semantic_state.remaining_required_bricks == 0, "clearing final required tile completes board")
	_assert(semantic_state.is_complete(), "board state reports completion at zero required bricks")

	var explosive_state = _board_state_from_level(_make_level_from_rows([
		[1, 2, 3],
		[4, 43, 68],
		[5, 6, 7],
	]))
	_assert(explosive_state.explode_at(1, 1) == 8, "chain explosion clears center and non-chain neighbors")
	_assert(explosive_state.tile_at(2, 1) == 68, "chain explosion leaves neighboring chain tile pending")
	_assert(explosive_state.pending_chain_explosion_count() == 1, "chain explosion schedules delayed neighbor")
	_assert(explosive_state.remaining_required_bricks == 1, "pending chain tile still counts until it fires")
	_assert(explosive_state.process_chain_explosions(0.029) == 0, "chain explosion waits for original 30ms delay")
	_assert(explosive_state.tile_at(2, 1) == 68, "chain tile remains before delay completes")
	_assert(explosive_state.process_chain_explosions(0.002) == 1, "chain explosion fires after original delay")
	_assert(explosive_state.tile_at(2, 1) == 0, "delayed chain tile clears when fired")
	_assert(explosive_state.remaining_required_bricks == 0, "delayed chain explosion updates completion count")

	var edge_state = _board_state_from_level(_make_level_from_rows([
		[43, 1],
		[2, 3],
	]))
	_assert(edge_state.explode_at(0, 0) == 4, "corner explosion clamps to board bounds")
	_assert(edge_state.remaining_required_bricks == 0, "corner explosion clears only valid neighbors")


func _validate_brick_atlas_mapping() -> void:
	var mapping: BrickAtlasMapping = BrickAtlasMappingScript.new()
	_assert(mapping.is_empty_tile(0), "brick mapping skips empty tile")
	_assert(mapping.is_empty_tile(170), "brick mapping skips high non-visual tile")
	_assert(not mapping.is_empty_tile(161), "brick mapping keeps highest visual tile")
	_assert(mapping.source_rect_for_tile(1) == Rect2(Vector2(0, 0), Vector2(20, 30)), "brick tile 1 maps to first row")
	_assert(mapping.source_rect_for_tile(19) == Rect2(Vector2(0, 540), Vector2(20, 30)), "brick tile 19 maps by tile id row")
	_assert(mapping.source_rect_for_tile(68, 2) == Rect2(Vector2(40, 2010), Vector2(20, 30)), "animated tile 68 uses animation frame column")
	_assert(mapping.source_rect_for_tile(161, 3) == Rect2(Vector2(60, 4800), Vector2(20, 30)), "highest animated tile stays within Bricks sheet")
	_assert(mapping.visual_frame_for_tile(20, 3) == 0, "static brick ignores animation frame")
	_assert(mapping.visual_frame_for_tile(68, 3) == 3, "animated brick accepts animation frame")


func _validate_level_grid_renderer_defaults() -> void:
	var renderer: LevelGridRenderer = LevelGridRendererScript.new()
	_assert(renderer.origin == PlayfieldSpecScript.GRID_ORIGIN, "level renderer uses shared grid origin")
	_assert(renderer.tile_size == PlayfieldSpecScript.BRICK_SIZE, "level renderer uses shared brick size")
	_assert(renderer.default_episode == PlayfieldSpecScript.DEFAULT_EPISODE, "level renderer uses shared default episode")
	_assert(renderer.default_level_number == PlayfieldSpecScript.DEFAULT_LEVEL_NUMBER, "level renderer uses shared default level")
	renderer.free()


func _validate_gameplay_sheet_catalog() -> void:
	var expected_sheets: Array[String] = [
		"Backgr",
		"Balls",
		"Bee",
		"Bonuses_a",
		"Bonuses_aa",
		"Bricks",
		"Bullets",
		"Clock",
		"DigitsSmall",
		"Exploision",
		"Fb",
		"InfoIcons",
		"Monsters",
		"PointToBonusInStack",
		"Racket",
		"Roller",
		"Snake",
		"Statistic",
		"Walls",
	]

	var catalog_sheets := GameplaySheetCatalogScript.sheet_names()
	_assert(catalog_sheets.size() == expected_sheets.size(), "gameplay sheet catalog has expected sheet count")

	for sheet_name: String in expected_sheets:
		_assert(GameplaySheetCatalogScript.has_sheet(sheet_name), "gameplay sheet is cataloged: %s" % sheet_name)
		var texture_name := GameplaySheetCatalogScript.texture_name_for(sheet_name)
		var texture_path: String = _assets.texture_path(texture_name)
		_assert(not texture_path.is_empty(), "gameplay sheet texture is indexed: %s" % sheet_name)
		if texture_path.is_empty():
			continue

		var texture := load(texture_path) as Texture2D
		_assert(texture != null, "gameplay sheet texture loads: %s" % sheet_name)
		if texture == null:
			continue

		var actual_size := Vector2i(texture.get_width(), texture.get_height())
		_assert(
			actual_size == GameplaySheetCatalogScript.expected_size_for(sheet_name),
			"gameplay sheet dimensions match extracted asset: %s" % sheet_name
		)

	_assert(GameplaySheetCatalogScript.has_verified_frame_layout("Bricks"), "brick sheet has verified frame layout")
	_assert(
		GameplaySheetCatalogScript.verified_frame_rect_for("Bricks", 5) == Rect2(Vector2(0, 30), Vector2(20, 30)),
		"brick sheet verified frame rect advances by atlas columns"
	)
	_assert(
		GameplaySheetCatalogScript.verified_frame_rect_for("Racket", 0) == Rect2(),
		"unknown sheet frame layout remains unmapped"
	)


func _validate_menu_and_game_scenes() -> void:
	_assert(ResourceLoader.exists("res://scenes/menu/main_menu_screen.tscn"), "main menu scene exists")
	_assert(ResourceLoader.exists("res://scenes/menu/episode_select_screen.tscn"), "episode select scene exists")
	_assert(ResourceLoader.exists("res://scenes/game/game_screen.tscn"), "game screen scene exists")

	var menu := MainMenuScreenScene.instantiate()
	root.add_child(menu)
	await process_frame

	_assert(menu.has_signal("start_game_requested"), "main menu exposes start game signal")
	_assert(menu.has_signal("rules_requested"), "main menu exposes rules signal")
	_assert(menu.has_signal("high_score_requested"), "main menu exposes high score signal")
	_assert(menu.has_signal("options_requested"), "main menu exposes options signal")
	_assert(menu.has_signal("credits_requested"), "main menu exposes credits signal")
	_assert(menu.has_signal("quit_requested"), "main menu exposes quit signal")
	_assert(menu.find_child("Background", true, false) != null, "main menu creates background art")
	_assert(menu.find_child("Title", true, false) != null, "main menu creates title art")
	_assert(menu.find_child("SelectedCaption", true, false) != null, "main menu creates selected caption")

	var expected_menu_items := {
		"RulesButton": Vector2(30, 190),
		"StartGameButton": Vector2(270, 190),
		"HighScoreButton": Vector2(510, 190),
		"OptionsButton": Vector2(150, 270),
		"CreditsButton": Vector2(390, 270),
		"ExitButton": Vector2(270, 350),
	}
	for button_name: String in expected_menu_items.keys():
		var item_button := menu.find_child(button_name, true, false) as TextureButton
		_assert(item_button != null, "main menu creates original icon button: %s" % button_name)
		if item_button == null:
			continue
		_assert(item_button.position == expected_menu_items[button_name], "main menu icon position matches original: %s" % button_name)
		_assert(item_button.texture_normal is AtlasTexture, "main menu icon uses atlas texture: %s" % button_name)

	_assert(menu.has_method("selected_caption"), "main menu exposes selected caption for tests")
	if menu.has_method("selected_caption"):
		_assert(menu.call("selected_caption") == "Start New Game", "main menu defaults to start caption")

	var start_button := menu.find_child("StartGameButton", true, false) as TextureButton
	_assert(start_button != null, "main menu creates start game button")
	if start_button != null:
		var signal_state := {"did_request_start": false}
		menu.start_game_requested.connect(func() -> void: signal_state["did_request_start"] = true)
		start_button.emit_signal("pressed")
		await process_frame
		_assert(signal_state["did_request_start"], "start game button emits start request")

	var rules_button := menu.find_child("RulesButton", true, false) as TextureButton
	if rules_button != null:
		var rules_signal_state := {"did_request_rules": false}
		menu.rules_requested.connect(func() -> void: rules_signal_state["did_request_rules"] = true)
		rules_button.emit_signal("pressed")
		await process_frame
		_assert(rules_signal_state["did_request_rules"], "rules button emits stub request")
	menu.queue_free()

	var episode_select := EpisodeSelectScreenScene.instantiate()
	root.add_child(episode_select)
	await process_frame

	_assert(episode_select.has_signal("episode_selected"), "episode select exposes episode selected signal")
	_assert(episode_select.has_signal("back_requested"), "episode select exposes back signal")
	_assert(episode_select.call("episode_count") == 17, "episode select lists all extracted episodes")
	_assert(episode_select.call("page_count") == 2, "episode select paginates extracted episodes")
	_assert(episode_select.call("visible_row_count") == 10, "episode select shows ten rows on first page")
	_assert(episode_select.find_child("PageStatus", true, false) != null, "episode select creates page status")
	_assert(episode_select.find_child("UpButton", true, false) != null, "episode select creates up arrow")
	_assert(episode_select.find_child("DownButton", true, false) != null, "episode select creates down arrow")

	var selected_summary: Dictionary = episode_select.call("selected_episode_summary")
	_assert(selected_summary.get("slug", "") == "Abstraction", "episode select defaults to first sorted episode")

	var down_button := episode_select.find_child("DownButton", true, false) as TextureButton
	if down_button != null:
		down_button.emit_signal("pressed")
		await process_frame
		_assert(episode_select.call("current_page") == 1, "episode select down arrow advances page")
		_assert(episode_select.call("visible_row_count") == 7, "episode select second page shows remaining episodes")

	var episode_signal_state := {
		"did_select_episode": false,
		"slug": "",
		"level_number": 0,
	}
	episode_select.episode_selected.connect(func(slug: String, level_number: int) -> void:
		episode_signal_state["did_select_episode"] = true
		episode_signal_state["slug"] = slug
		episode_signal_state["level_number"] = level_number
	)
	var first_row_button := episode_select.find_child("EpisodeRowButton1", true, false) as Button
	if first_row_button != null:
		first_row_button.emit_signal("pressed")
		await process_frame
		_assert(episode_signal_state["did_select_episode"], "episode row emits episode selected")
		_assert(not String(episode_signal_state["slug"]).is_empty(), "episode selection includes slug")
		_assert(episode_signal_state["level_number"] == 1, "episode selection starts at first level")
	episode_select.queue_free()

	var game := GameScreenScene.instantiate()
	_assert(game.episode_slug == PlayfieldSpecScript.DEFAULT_EPISODE, "game screen defaults to shared episode")
	_assert(game.level_number == PlayfieldSpecScript.DEFAULT_LEVEL_NUMBER, "game screen defaults to shared level number")
	root.add_child(game)
	await process_frame

	var playfield := game.find_child("PlayfieldRenderer", true, false)
	_assert(playfield != null, "game screen creates playfield renderer")
	if playfield != null:
		_assert(playfield.default_episode == PlayfieldSpecScript.DEFAULT_EPISODE, "game screen configures playfield episode")
		_assert(playfield.default_level_number == PlayfieldSpecScript.DEFAULT_LEVEL_NUMBER, "game screen configures playfield level")
		_assert(playfield.level_data != null, "game screen loads default level data")
		_assert(playfield.board_state != null, "game screen creates mutable board state")
	game.queue_free()

	var app := AppScene.instantiate()
	root.add_child(app)
	await process_frame

	var app_menu := app.find_child("MainMenuScreen", true, false)
	_assert(app_menu != null, "app starts on main menu screen")
	if app_menu != null:
		app_menu.emit_signal("start_game_requested")
		await process_frame
		var app_episode_select := app.find_child("EpisodeSelectScreen", true, false)
		_assert(app_episode_select != null, "app switches from menu to episode select screen")
		if app_episode_select != null:
			app_episode_select.emit_signal("episode_selected", "Retro", 1)
			await process_frame
			var app_game := app.find_child("GameScreen", true, false)
			_assert(app_game != null, "app switches from episode select to game screen")
			if app_game != null:
				_assert(app_game.episode_slug == "Retro", "app starts selected episode")
				_assert(app_game.level_number == 1, "app starts selected episode at first level")
	app.queue_free()


func _load_level_from_path(path: String):
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return null

	return LevelDataScript.from_dictionary(parsed, path)


func _make_level_from_rows(source_rows: Array) -> KrakoutLevelData:
	var level: KrakoutLevelData = LevelDataScript.new()
	level.columns = LevelDataScript.COLUMNS
	level.rows_count = LevelDataScript.ROWS
	for row_index in range(LevelDataScript.ROWS):
		var source_row: Array = source_rows[row_index] if row_index < source_rows.size() else []
		var row: Array[int] = []
		for column in range(LevelDataScript.COLUMNS):
			var value := 0
			if column < source_row.size():
				value = int(source_row[column])
			row.append(value)
		level.tile_ids.append(row)
	return level


func _board_state_from_level(level: KrakoutLevelData):
	var state = BoardStateScript.new()
	state.load_level(level)
	return state


func _is_runtime_path(entry: Dictionary) -> bool:
	return String(entry.get("output_path", "")).begins_with("res://assets/krakout/")


func _find_summary(summaries: Array, slug: String) -> Dictionary:
	for summary: Dictionary in summaries:
		if summary.get("slug", "") == slug:
			return summary
	return {}


func _assert(condition: bool, message: String) -> void:
	if condition:
		return

	_failures += 1
	push_error(message)
