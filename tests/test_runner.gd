extends SceneTree

const AssetsScript := preload("res://src/autoloads/krakout_assets.gd")
const LevelsScript := preload("res://src/autoloads/krakout_levels.gd")
const ProfileScript := preload("res://src/autoloads/krakout_profile.gd")
const AudioScript := preload("res://src/autoloads/krakout_audio.gd")
const AudioCueCatalogScript := preload("res://src/audio/krakout_audio_cue_catalog.gd")
const LevelDataScript := preload("res://src/data/krakout_level_data.gd")
const HighScoreFileScript := preload("res://src/data/krakout_high_score_file.gd")
const LevelGridRendererScript := preload("res://src/render/level_grid_renderer.gd")
const BrickAtlasMappingScript := preload("res://src/render/brick_atlas_mapping.gd")
const GameplaySheetCatalogScript := preload("res://src/playfield/krakout_gameplay_sheet_catalog.gd")
const PlayfieldSpecScript := preload("res://src/playfield/krakout_playfield_spec.gd")
const PlayfieldRendererScript := preload("res://src/playfield/playfield_renderer.gd")
const BrickSemanticsScript := preload("res://src/gameplay/krakout_brick_semantics.gd")
const BoardStateScript := preload("res://src/gameplay/krakout_board_state.gd")
const GameSessionScript := preload("res://src/gameplay/krakout_game_session.gd")
const RandomScript := preload("res://src/gameplay/krakout_random.gd")
const RacketRendererScript := preload("res://src/render/racket_renderer.gd")
const BallRendererScript := preload("res://src/render/ball_renderer.gd")
const BonusRendererScript := preload("res://src/render/bonus_renderer.gd")
const BulletRendererScript := preload("res://src/render/bullet_renderer.gd")
const MonsterRendererScript := preload("res://src/render/monster_renderer.gd")
const BeeRendererScript := preload("res://src/render/bee_renderer.gd")
const SnakeRendererScript := preload("res://src/render/snake_renderer.gd")
const ImpactEffectRendererScript := preload("res://src/render/impact_effect_renderer.gd")
const ScorePopupRendererScript := preload("res://src/render/score_popup_renderer.gd")
const LevelReadyRollerRendererScript := preload("res://src/render/level_ready_roller_renderer.gd")
const GameHudScript := preload("res://src/game/game_hud.gd")
const GameScreenScript := preload("res://src/game/game_screen.gd")
const BitmapTextScript := preload("res://src/render/krakout_bitmap_text.gd")
const MenuBitmapLabelScript := preload("res://src/menu/krakout_menu_bitmap_label.gd")
const MenuAmbientEffectsScript := preload("res://src/menu/krakout_menu_ambient_effects.gd")
const StaticMenuBackButtonScript := preload("res://src/menu/static_menu_back_button.gd")
const OptionsVxEffectsScript := preload("res://src/menu/options_vx_effects.gd")
const WaveBitmapLabelScript := preload("res://src/menu/krakout_wave_bitmap_label.gd")
const OptionsScreenScript := preload("res://src/menu/options_screen.gd")
const MainMenuScreenScript := preload("res://src/menu/main_menu_screen.gd")
const ExitConfirmScreenScript := preload("res://src/menu/exit_confirm_screen.gd")
const EpisodeSelectScreenScript := preload("res://src/menu/episode_select_screen.gd")
const RulesScreenScript := preload("res://src/menu/rules_screen.gd")
const CreditsScreenScript := preload("res://src/menu/credits_screen.gd")
const NameEntryScreenScript := preload("res://src/menu/name_entry_screen.gd")
const MainMenuScreenScene := preload("res://scenes/menu/main_menu_screen.tscn")
const ExitConfirmScreenScene := preload("res://scenes/menu/exit_confirm_screen.tscn")
const EpisodeSelectScreenScene := preload("res://scenes/menu/episode_select_screen.tscn")
const RulesScreenScene := preload("res://scenes/menu/rules_screen.tscn")
const HighScoreScreenScene := preload("res://scenes/menu/high_score_screen.tscn")
const NameEntryScreenScene := preload("res://scenes/menu/name_entry_screen.tscn")
const OptionsScreenScene := preload("res://scenes/menu/options_screen.tscn")
const CreditsScreenScene := preload("res://scenes/menu/credits_screen.tscn")
const GameScreenScene := preload("res://scenes/game/game_screen.tscn")
const AppScene := preload("res://scenes/app/app.tscn")

var _failures := 0
var _assets: Node
var _levels: Node
var _profile: Node
var _audio: Node


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
	_assert(_assets.texture_path("Cursor") == "res://assets/krakout/textures/Cursor.png", "Cursor texture path is indexed")
	_assert(_assets.texture_path("Welogo") == "res://assets/krakout/textures/Welogo.png", "Welogo texture path is indexed")
	_assert(_assets.music_path("theme1") == "res://assets/krakout/audio/music/theme1.ogg", "theme1 music path is indexed")
	_assert(ResourceLoader.exists(_assets.texture_path("Bricks")), "Bricks texture is loadable")
	_assert(ResourceLoader.exists(_assets.texture_path("Cursor")), "Cursor texture is loadable")
	_assert(ResourceLoader.exists(_assets.texture_path("Welogo")), "Welogo texture is loadable")
	_assert(ResourceLoader.exists(_assets.music_path("theme1")), "theme1 music is loadable")
	var cursor_texture := _assets.load_texture("Cursor") as Texture2D
	_assert(
		cursor_texture != null and Vector2i(cursor_texture.get_width(), cursor_texture.get_height()) == Vector2i(68, 58),
		"Cursor texture preserves extracted 68x58 dimensions"
	)
	var welogo_texture := _assets.load_texture("Welogo") as Texture2D
	_assert(
		welogo_texture != null and Vector2i(welogo_texture.get_width(), welogo_texture.get_height()) == Vector2i(200, 240),
		"Welogo texture preserves extracted 5x6 40px animation sheet dimensions"
	)
	var arrow_up_texture := _assets.load_texture("Arrowup") as Texture2D
	_assert(arrow_up_texture != null, "Arrowup texture is loadable")
	if arrow_up_texture != null:
		var arrow_up_image := arrow_up_texture.get_image()
		_assert(arrow_up_image != null, "Arrowup texture exposes image data")
		if arrow_up_image != null:
			_assert(
				is_zero_approx(arrow_up_image.get_pixel(0, 0).a),
				"Arrowup texture converts black key color to transparent background"
			)
	var episode_background_texture := _assets.load_texture("BgEpisode") as Texture2D
	_assert(episode_background_texture != null, "BgEpisode texture is loadable")
	if episode_background_texture != null:
		var episode_background_image := episode_background_texture.get_image()
		_assert(episode_background_image != null, "BgEpisode texture exposes image data")
		if episode_background_image != null:
			_assert(
				is_zero_approx(episode_background_image.get_pixel(0, 0).a),
				"BgEpisode texture converts black key color to transparent background"
			)
			_assert(
				is_equal_approx(episode_background_image.get_pixel(23, 0).a, 1.0),
				"BgEpisode keeps first grid tile pixels opaque"
			)
			_assert(
				is_equal_approx(episode_background_image.get_pixel(60, 0).a, 1.0),
				"BgEpisode keeps second grid tile pixels opaque"
			)
	var name_entry_background_texture := _assets.load_texture("BgGetName") as Texture2D
	_assert(name_entry_background_texture != null, "BgGetName texture is loadable")
	if name_entry_background_texture != null:
		var name_entry_background_image := name_entry_background_texture.get_image()
		_assert(name_entry_background_image != null, "BgGetName texture exposes image data")
		if name_entry_background_image != null:
			_assert(
				is_zero_approx(name_entry_background_image.get_pixel(0, 0).a),
				"BgGetName texture converts black key color to transparent background"
			)
			_assert(
				is_equal_approx(name_entry_background_image.get_pixel(23, 0).a, 1.0),
				"BgGetName keeps first grid tile pixels opaque"
			)
			_assert(
				is_equal_approx(name_entry_background_image.get_pixel(60, 0).a, 1.0),
				"BgGetName keeps second grid tile pixels opaque"
			)
	var walls_texture := _assets.load_texture("Walls") as Texture2D
	_assert(walls_texture != null, "Walls texture is loadable")
	if walls_texture != null:
		var walls_image := walls_texture.get_image()
		_assert(walls_image != null, "Walls texture exposes image data")
		if walls_image != null:
			_assert(
				is_zero_approx(walls_image.get_pixel(0, 0).a),
				"Walls texture converts original palette-index-0 key color to transparent background"
			)
			_assert(
				is_equal_approx(walls_image.get_pixel(20, 20).a, 1.0),
				"Walls texture keeps non-key wall pixels opaque"
			)

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
		var default_bonus_counts: Array[int] = level.bonus_stock_counts()
		_assert(default_bonus_counts.size() == LevelDataScript.BONUS_STOCK_COUNT_SIZE, "Default level exposes 22 bonus stock counters")
		_assert(default_bonus_counts[14] == 5, "Default level bonus stock mirrors preserved tail bytes")
		_assert(level.tile_semantics == "unmapped", "Default level tile semantics stay unmapped")
		_assert(level.populated_tile_count() > 0, "Default level contains non-empty raw tiles")
		_validate_board_state(level)
		_validate_game_session(level)

	_validate_playfield_spec()
	_validate_project_presentation_settings()
	_validate_project_input_map()
	_validate_legacy_high_score_file()
	_validate_profile_service()
	_validate_audio_cue_catalog()
	await _validate_audio_service()
	_validate_playfield_renderer_shell()
	_validate_brick_semantics()
	_validate_original_rng()
	_validate_brick_atlas_mapping()
	_validate_bitmap_text_metrics()
	await _validate_menu_bitmap_label()
	_validate_level_grid_renderer_defaults()
	await _validate_game_hud_presentation()
	_validate_gameplay_sheet_catalog()
	_validate_menu_ambient_effects()
	_validate_options_vx_effects()
	_validate_manifest_paths()
	await _validate_menu_and_game_scenes()
	_shutdown_test_audio()
	await process_frame

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

	_profile = root.get_node_or_null("KrakoutProfile")
	if _profile == null:
		_profile = ProfileScript.new()
		_profile.name = "KrakoutProfile"
		root.add_child(_profile)
	if _profile.has_method("set_save_path"):
		_profile.call("set_save_path", _test_profile_path("autoload"), false)

	_audio = root.get_node_or_null("KrakoutAudio")
	if _audio == null:
		_audio = AudioScript.new()
		_audio.name = "KrakoutAudio"
		root.add_child(_audio)


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
		var default_level_numbers: Array[int] = _levels.level_numbers("Default")
		_assert(default_level_numbers.size() == 14, "level catalog exposes Default level numbers")
		_assert(default_level_numbers[0] == 1, "level catalog sorts first Default level")
		_assert(default_level_numbers[default_level_numbers.size() - 1] == 14, "level catalog sorts final Default level")
		_assert(_levels.wrapped_level_number("Default", 15) == 1, "level catalog wraps displayed level numbers")
		var wrapped_level: KrakoutLevelData = _levels.load_wrapped_level("Default", 15)
		_assert(wrapped_level != null, "level catalog loads wrapped level")
		if wrapped_level != null:
			_assert(wrapped_level.level_number == 1, "wrapped level keeps source level number")

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
	_assert(PlayfieldSpecScript.WALL_INNER_LEFT_X == 27.0, "left wall inner collision line matches original")
	_assert(PlayfieldSpecScript.WALL_INNER_TOP_Y == 63.0, "top wall inner collision line matches original")
	_assert(PlayfieldSpecScript.WALL_INNER_RIGHT_X == 613.0, "right wall inner collision line matches original")
	_assert(PlayfieldSpecScript.WALL_INNER_BOTTOM_Y == 453.0, "bottom wall inner collision line matches original")
	_assert(PlayfieldSpecScript.wall_inner_rect() == Rect2(Vector2(27, 63), Vector2(586, 390)), "wall inner collision rect is stable")


func _validate_playfield_renderer_shell() -> void:
	var renderer: PlayfieldRenderer = PlayfieldRendererScript.new()
	_assert(renderer.gameplay_background_source_rect() == Rect2(Vector2(100, 0), Vector2(50, 50)), "playfield renderer uses original lattice background tile")
	_assert(renderer.background_type == PlayfieldRendererScript.DEFAULT_BACKGROUND_TYPE, "playfield renderer defaults to original background type")
	_assert(renderer.is_background_movable(), "playfield renderer preserves movable background setting")
	_assert(renderer.background_source_rect_for_type(0) == Rect2(Vector2.ZERO, Vector2(50, 50)), "playfield renderer maps first background source tile")
	_assert(renderer.background_source_rect_for_type(4) == Rect2(Vector2(0, 50), Vector2(50, 50)), "playfield renderer maps second-row background tiles")
	_assert(renderer.background_source_rect_for_type(7) == Rect2(Vector2(150, 50), Vector2(50, 50)), "playfield renderer maps the final original background tile")
	renderer.set_background_type(1)
	_assert(renderer.gameplay_background_source_rect() == Rect2(Vector2(50, 0), Vector2(50, 50)), "playfield renderer can switch background source tile")
	_assert(renderer.cycle_background_type() == 2, "playfield renderer cycles background source tiles")
	renderer.set_background_type(99)
	_assert(renderer.background_type == 0, "playfield renderer resets out-of-range background types to the original first entry")
	_assert(renderer.current_background_scroll_offset() == 0.0, "playfield renderer starts the original moving-background phase at zero")
	renderer.advance_background(PlayfieldRendererScript.BACKGROUND_SCROLL_GATE_SECONDS)
	_assert(renderer.current_background_scroll_offset() == 0.0, "playfield renderer keeps the background phase until the original strict timer gate passes")
	renderer.advance_background(0.001)
	_assert(renderer.current_background_scroll_offset() == 1.0, "playfield renderer advances background phase by one pixel after the original timer gate")
	_assert(
		renderer.background_tile_target_rect(Vector2.ZERO) == Rect2(Vector2(-1, 1), PlayfieldRendererScript.BACKGROUND_TILE_SIZE),
		"playfield renderer offsets original background tiles diagonally"
	)
	renderer.set_background_movable(false)
	_assert(not renderer.is_background_movable(), "playfield renderer records background movable setting")
	renderer.advance_background(1.0)
	_assert(renderer.current_background_scroll_offset() == 1.0, "playfield renderer freezes background phase when motion is disabled")
	renderer.set_background_movable(true)
	for _index in range(int(PlayfieldRendererScript.BACKGROUND_SCROLL_WRAP_PIXELS) - 1):
		renderer.advance_background(PlayfieldRendererScript.BACKGROUND_SCROLL_GATE_SECONDS + 0.001)
	_assert(renderer.current_background_scroll_offset() == 0.0, "playfield renderer wraps moving-background phase at one original tile")
	_assert(renderer.current_wall_horizontal_scroll_offset() == 0.0, "playfield renderer starts horizontal wall phase at zero")
	_assert(renderer.current_wall_vertical_scroll_offset() == 0.0, "playfield renderer starts vertical wall phase at zero")
	_assert(renderer.top_wall_repeat_start_x() == PlayfieldRendererScript.WALL_REPEAT_STEP, "top wall repeat starts one tile in at phase zero")
	_assert(renderer.bottom_wall_repeat_start_x() == 0.0, "bottom wall repeat starts at screen edge at phase zero")
	_assert(renderer.left_wall_repeat_start_y() == PlayfieldRendererScript.WALL_SIDE_BASE_Y, "left wall repeat starts at original side base y")
	_assert(renderer.back_wall_repeat_start_y() == PlayfieldSpecScript.WALL_INNER_TOP_Y, "back wall repeat starts at original inner top")
	renderer.advance_wall_animation()
	_assert(renderer.current_wall_horizontal_scroll_offset() == 1.0, "playfield renderer advances horizontal wall phase by one pixel per frame")
	_assert(renderer.current_wall_vertical_scroll_offset() == 1.0, "playfield renderer advances vertical wall phase by one pixel per frame")
	_assert(renderer.top_wall_repeat_start_x() == PlayfieldRendererScript.WALL_REPEAT_STEP - 1.0, "top wall scrolls left from the original phase")
	_assert(renderer.bottom_wall_repeat_start_x() == 1.0, "bottom wall scrolls right from the original phase")
	_assert(renderer.left_wall_repeat_start_y() == PlayfieldRendererScript.WALL_SIDE_BASE_Y + 1.0, "left wall scrolls down from the original phase")
	_assert(renderer.back_wall_repeat_start_y() == PlayfieldSpecScript.WALL_INNER_TOP_Y - 1.0, "back wall scrolls up from the original phase")
	for _index in range(int(PlayfieldRendererScript.WALL_SCROLL_WRAP_PIXELS) - 1):
		renderer.advance_wall_animation()
	_assert(renderer.current_wall_horizontal_scroll_offset() == 0.0, "playfield renderer wraps horizontal wall phase at one wall tile")
	_assert(renderer.current_wall_vertical_scroll_offset() == 0.0, "playfield renderer wraps vertical wall phase at one wall tile")
	_assert(PlayfieldRendererScript.WALL_LEFT_X == 2, "left wall x remains original-screen aligned")
	_assert(PlayfieldRendererScript.WALL_RIGHT_X == 613, "right wall x remains original-screen aligned")
	_assert(PlayfieldRendererScript.WALL_TOP_Y == 36, "top wall y remains original-screen aligned")
	_assert(PlayfieldRendererScript.WALL_TOP_REPEAT_Y == 38, "top repeated wall strip keeps original two-pixel inset")
	_assert(PlayfieldRendererScript.WALL_BOTTOM_Y == 453, "bottom wall y remains original-screen aligned")
	_assert(PlayfieldRendererScript.WALL_SIDE_START_Y == 81, "side wall start remains original-screen aligned")
	_assert(PlayfieldSpecScript.WALL_INNER_LEFT_X == PlayfieldRendererScript.WALL_LEFT_X + PlayfieldRendererScript.WALL_SIDE_SOURCE.size.x, "left collision starts after left wall visual")
	_assert(PlayfieldSpecScript.WALL_INNER_RIGHT_X == PlayfieldRendererScript.WALL_RIGHT_X, "right collision aligns to back wall visual")
	_assert(PlayfieldSpecScript.WALL_INNER_TOP_Y == PlayfieldSpecScript.GRID_ORIGIN.y, "top collision aligns to original grid top")
	_assert(PlayfieldSpecScript.WALL_INNER_BOTTOM_Y == PlayfieldRendererScript.WALL_BOTTOM_Y, "bottom collision aligns to bottom wall visual")
	_assert(not renderer.is_back_wall_active(), "playfield renderer starts with back wall hidden")
	renderer.set_back_wall_active(true)
	_assert(renderer.is_back_wall_active(), "playfield renderer can show timed back wall")
	renderer.free()


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
	_assert(BrickSemanticsScript.behavior_case(1) == 0, "tile 1 uses the bonus-eligible brick behavior case")
	_assert(BrickSemanticsScript.can_spawn_bonus(1), "tile 1 can route through original bonus spawn logic")
	_assert(BrickSemanticsScript.behavior_case(8) == 1, "tile 8 keeps its non-clear behavior case")
	_assert(BrickSemanticsScript.behavior_case(39) == 1, "tile 39 keeps its non-clear behavior case")
	_assert(BrickSemanticsScript.behavior_case(40) == 1, "tile 40 keeps its non-clear behavior case")
	_assert(BrickSemanticsScript.behavior_case(43) == 4, "tile 43 keeps its chain behavior case")
	_assert(BrickSemanticsScript.behavior_case(68) == 4, "tile 68 keeps its chain behavior case")
	_assert(BrickSemanticsScript.behavior_case(69) == 1, "tile 69 keeps its non-clear behavior case")
	_assert(not BrickSemanticsScript.can_spawn_bonus(43), "chain tiles do not route through bonus spawn logic")
	_assert(BrickSemanticsScript.hit_kind(1) == BrickSemanticsScript.HIT_KIND_NORMAL, "tile 1 uses normal hit behavior")
	_assert(BrickSemanticsScript.hit_kind(8) == BrickSemanticsScript.HIT_KIND_FORCE_BREAK_ONLY, "tile 8 only clears under force-break hits")
	_assert(BrickSemanticsScript.hit_kind(15) == BrickSemanticsScript.HIT_KIND_DOWNGRADE, "tile 15 uses original downgrade behavior")
	_assert(BrickSemanticsScript.hit_kind(43) == BrickSemanticsScript.HIT_KIND_CHAIN_EXPLOSION, "tile 43 uses chain hit behavior")
	_assert(BrickSemanticsScript.downgraded_tile_id(15) == 14, "tile 15 downgrades to original next stage")
	_assert(BrickSemanticsScript.downgraded_tile_id(42) == 44, "tile 42 downgrades to original animated next stage")
	_assert(BrickSemanticsScript.downgraded_tile_id(70) == 90, "tile 70 downgrades to original high-range next stage")
	_assert(BrickSemanticsScript.one_strike_tile_id(8) == 7, "one-strike bonus weakens tile 8 through the original table")
	_assert(BrickSemanticsScript.one_strike_tile_id(15) == 14, "one-strike bonus weakens tile 15 through the original table")
	_assert(BrickSemanticsScript.one_strike_tile_id(40) == 14, "one-strike bonus weakens tile 40 through the original table")
	_assert(BrickSemanticsScript.one_strike_tile_id(69) == 32, "one-strike bonus weakens tile 69 through the original table")
	_assert(BrickSemanticsScript.one_strike_tile_id(70) == 24, "one-strike bonus weakens tile 70 through the original table")
	_assert(BrickSemanticsScript.one_strike_tile_id(90) == 24, "one-strike bonus weakens tile 90 through the original table")
	_assert(BrickSemanticsScript.one_strike_tile_id(101) == 67, "one-strike bonus weakens tile 101 through the original table")
	_assert(BrickSemanticsScript.one_strike_tile_id(133) == 132, "one-strike bonus weakens tile 133 through the original table")
	_assert(BrickSemanticsScript.one_strike_tile_id(145) == 144, "one-strike bonus weakens tile 145 through the original table")
	_assert(BrickSemanticsScript.one_strike_tile_id(1) == 1, "one-strike bonus leaves ordinary one-hit bricks unchanged")


func _validate_original_rng() -> void:
	var rng = RandomScript.new(17)
	_assert(rng.next_mod(2) == 0, "original RNG produces deterministic modulo values")
	_assert(rng.next_mod(23) == 0, "original RNG advances state between calls")


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
	var explosion_result: Dictionary = explosive_state.explode_at_with_result(1, 1)
	var explosion_cells: Array = explosion_result["cleared_cells"]
	_assert(int(explosion_result["cleared_count"]) == 8, "chain explosion clears center and non-chain neighbors")
	_assert(explosion_cells.size() == 8, "chain explosion result exposes every immediate cleared cell")
	_assert(explosion_cells.has(Vector2i(1, 1)), "chain explosion result includes the source cell")
	_assert(explosion_cells.has(Vector2i(0, 0)), "chain explosion result includes non-chain neighbors")
	_assert(not explosion_cells.has(Vector2i(2, 1)), "chain explosion result excludes pending chain neighbors")
	_assert(explosive_state.tile_at(2, 1) == 68, "chain explosion leaves neighboring chain tile pending")
	_assert(explosive_state.pending_chain_explosion_count() == 1, "chain explosion schedules delayed neighbor")
	_assert(explosive_state.remaining_required_bricks == 1, "pending chain tile still counts until it fires")
	var early_chain_result: Dictionary = explosive_state.process_chain_explosions_with_result(0.029)
	_assert(int(early_chain_result["cleared_count"]) == 0, "chain explosion waits for original 30ms delay")
	_assert(Array(early_chain_result["cleared_cells"]).is_empty(), "early chain explosion result has no cleared cells")
	_assert(explosive_state.tile_at(2, 1) == 68, "chain tile remains before delay completes")
	var delayed_chain_result: Dictionary = explosive_state.process_chain_explosions_with_result(0.002)
	var delayed_chain_cells: Array = delayed_chain_result["cleared_cells"]
	_assert(int(delayed_chain_result["cleared_count"]) == 1, "chain explosion fires after original delay")
	_assert(delayed_chain_cells == [Vector2i(2, 1)], "delayed chain explosion result exposes the fired cell")
	_assert(explosive_state.tile_at(2, 1) == 0, "delayed chain tile clears when fired")
	_assert(explosive_state.remaining_required_bricks == 0, "delayed chain explosion updates completion count")

	var edge_state = _board_state_from_level(_make_level_from_rows([
		[43, 1],
		[2, 3],
	]))
	_assert(edge_state.explode_at(0, 0) == 4, "corner explosion clamps to board bounds")
	_assert(edge_state.remaining_required_bricks == 0, "corner explosion clears only valid neighbors")

	var converted_chain_state = _board_state_from_level(_make_level_from_rows([[1]]))
	_assert(converted_chain_state.convert_to_chain_explosion_tile(0, 0, 68), "board state can convert a tile into a delayed chain explosion")
	_assert(converted_chain_state.tile_at(0, 0) == 68, "converted chain tile is stored in board state")
	_assert(converted_chain_state.pending_chain_explosion_count() == 1, "converted chain tile is scheduled")

	var low_block_chain_state = _board_state_from_level(_make_level_from_rows([[1, 8, 43, 68, 162]]))
	_assert(low_block_chain_state.convert_required_bricks_to_chain_explosions(43, 3.0) == 1, "low-block helper converts only remaining ordinary required bricks")
	_assert(low_block_chain_state.tile_at(0, 0) == 43, "low-block helper rewrites eligible bricks to original tile 43")
	_assert(low_block_chain_state.tile_at(1, 0) == 8, "low-block helper preserves force-break-only non-required bricks")
	_assert(low_block_chain_state.tile_at(2, 0) == 43, "low-block helper preserves existing tile 43 chain bricks")
	_assert(low_block_chain_state.tile_at(3, 0) == 68, "low-block helper preserves existing tile 68 chain bricks")
	_assert(low_block_chain_state.pending_chain_explosion_count() == 1, "low-block helper schedules converted tile only")

	var one_strike_state = _board_state_from_level(_make_level_from_rows([[8, 15, 40, 39, 42, 69, 70, 71, 101, 133, 137, 139, 141, 143, 145, 1]]))
	_assert(one_strike_state.weaken_all_for_one_strike() == 15, "one-strike board helper weakens every mapped original tile")
	_assert(one_strike_state.tile_at(0, 0) == 7, "one-strike board helper maps tile 8 to 7")
	_assert(one_strike_state.tile_at(1, 0) == 14, "one-strike board helper maps tile 15 to 14")
	_assert(one_strike_state.tile_at(2, 0) == 14, "one-strike board helper maps tile 40 to 14")
	_assert(one_strike_state.tile_at(3, 0) == 37, "one-strike board helper maps tile 39 to 37")
	_assert(one_strike_state.tile_at(4, 0) == 44, "one-strike board helper maps tile 42 to 44")
	_assert(one_strike_state.tile_at(5, 0) == 32, "one-strike board helper maps tile 69 to 32")
	_assert(one_strike_state.tile_at(6, 0) == 24, "one-strike board helper maps tile 70 to 24")
	_assert(one_strike_state.tile_at(7, 0) == 16, "one-strike board helper maps tile 71 to 16")
	_assert(one_strike_state.tile_at(8, 0) == 67, "one-strike board helper maps tile 101 to 67")
	_assert(one_strike_state.tile_at(9, 0) == 132, "one-strike board helper maps tile 133 to 132")
	_assert(one_strike_state.tile_at(10, 0) == 136, "one-strike board helper maps tile 137 to 136")
	_assert(one_strike_state.tile_at(11, 0) == 138, "one-strike board helper maps tile 139 to 138")
	_assert(one_strike_state.tile_at(12, 0) == 140, "one-strike board helper maps tile 141 to 140")
	_assert(one_strike_state.tile_at(13, 0) == 142, "one-strike board helper maps tile 143 to 142")
	_assert(one_strike_state.tile_at(14, 0) == 144, "one-strike board helper maps tile 145 to 144")
	_assert(one_strike_state.tile_at(15, 0) == 1, "one-strike board helper leaves ordinary tile 1 unchanged")


func _validate_game_session(default_level: KrakoutLevelData) -> void:
	_assert(GameSessionScript.BONUS_TYPE_NAMES.size() == GameSessionScript.BONUS_TYPE_COUNT, "bonus catalog names every original type")
	_assert(GameSessionScript.bonus_type_name(0) == "Add standard Ball", "bonus catalog preserves first original type")
	_assert(GameSessionScript.bonus_type_name(20) == "Jump to Next Level", "bonus catalog preserves jump-to-level type")

	var session = GameSessionScript.new()
	session.load_level(default_level)
	_assert(session.state == GameSessionScript.STATE_READY, "game session starts ready")
	_assert(session.board_state != null, "game session owns board state")
	_assert(session.board_state.remaining_required_bricks == 143, "game session preserves required brick count")
	_assert(session.active_ball_count() == 1, "game session shows a ready ball")
	_assert(session.are_ball_tracks_enabled(), "game session defaults ball-track VFX to the original enabled state")
	_assert(session.visible_ball_tracks().is_empty(), "game session starts without spawned ball tracks")
	_assert(session.ball_rect(session.visible_balls()[0]).size == Vector2(18, 18), "game session defaults to original standard ball size")
	_assert(
		is_equal_approx(session.racket_rect().position.x - session.ball_rect(session.visible_balls()[0]).end.x, GameSessionScript.READY_BALL_GAP),
		"ready ball uses the original short paddle gap"
	)
	_assert(is_equal_approx(GameSessionScript.BALL_FRAME_SECONDS, 0.1), "ball animation uses the original 100 ms frame gate")
	var ready_ball_frame := int(session.visible_balls()[0].get("frame", 0))
	session.update(GameSessionScript.BALL_FRAME_SECONDS)
	_assert(
		int(session.visible_balls()[0].get("frame", 0)) == (ready_ball_frame + 1) % GameSessionScript.BALL_FRAME_COUNT,
		"ready ball animation advances even while the ball is attached to the racket"
	)
	var ready_enemy_session = _game_session_from_level(_make_level_from_rows([[1]]))
	ready_enemy_session.set_monster_rng_seed(3)
	var ready_enemy_ball_position: Vector2 = ready_enemy_session.first_ball_position()
	ready_enemy_session.update(GameSessionScript.MONSTER_SPAWN_INTERVAL_SECONDS)
	_assert(ready_enemy_session.state == GameSessionScript.STATE_READY, "enemy spawn does not launch the ready ball")
	_assert(ready_enemy_session.active_monster_count() == 1, "enemy spawn timer runs before the initial ball is launched")
	_assert(ready_enemy_session.first_ball_position() == ready_enemy_ball_position, "ready ball remains attached while enemies spawn")
	_assert(ready_enemy_session.first_ball_velocity().is_zero_approx(), "ready ball remains stationary while enemies spawn")
	_assert(ready_enemy_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_MONSTER_SPAWN], "ready enemy spawn queues semantic SFX event")
	_assert(session.racket_segment_count == GameSessionScript.RACKET_DEFAULT_SEGMENTS, "game session defaults to original racket segment count")
	_assert(session.current_racket_height() == GameSessionScript.RACKET_HEIGHT, "game session defaults to original racket height")
	_assert(session.current_racket_x() == GameSessionScript.RACKET_X, "game session starts with the original resting racket x")
	_assert(session.racket_rect().size == Vector2(GameSessionScript.RACKET_WIDTH, GameSessionScript.RACKET_HEIGHT), "game session default racket rect uses original size")
	_assert(session.current_racket_visual_mode() == GameSessionScript.RACKET_VISUAL_MODE_NORMAL, "game session starts with original normal racket insert")
	_assert(session.score == 0, "game session starts with zero score")
	_assert(session.displayed_score == 0, "game session starts with zero displayed score")
	_assert(is_equal_approx(GameSessionScript.sfx_pan100_for_source_x(0.0), -100.0), "game session SFX pan formula clamps the left screen edge")
	_assert(is_equal_approx(GameSessionScript.sfx_pan100_for_source_x(320.0), 0.0), "game session SFX pan formula centers at original x 320")
	_assert(is_equal_approx(GameSessionScript.sfx_pan100_for_source_x(640.0), 100.0), "game session SFX pan formula clamps the right screen edge")
	_assert(session.lives_remaining == GameSessionScript.INITIAL_LIVES, "game session starts with original spare ball count")
	_assert(session.points_to_next_extra_life == GameSessionScript.EXTRA_LIFE_SCORE_STEP, "game session starts with original extra life threshold")
	_assert(session.display_level_number == 1, "game session displays source level number")
	_assert(session.active_bonus_indicators().is_empty(), "game session exposes no active status indicators before timed effects exist")
	_assert(session.active_monster_count() == 0, "game session starts without active monsters")
	_assert(session.active_bee_count() == 0, "game session starts without active bees")
	_assert(session.visible_snake_segments().is_empty(), "game session starts without Snake VFX segments")
	_assert(session.visible_impact_effects().is_empty(), "game session starts without impact effects")
	_assert(session.visible_score_popups().is_empty(), "game session starts without score-popup VFX")
	_assert(not session.is_racket_stunned(), "game session starts with active racket control")
	_assert(session.pop_audio_events().is_empty(), "game session starts without queued SFX events")

	var direct_score_session = _game_session_from_level(_make_level_from_rows([[1]]))
	direct_score_session.award_score(30)
	_assert(direct_score_session.score == 30, "direct score award still updates the run score")
	_assert(direct_score_session.visible_score_popups().is_empty(), "direct score awards do not create original floating score VFX")

	var popup_motion_session = _game_session_from_level(_make_level_from_rows([[1]]))
	_assert(bool(popup_motion_session.call("_spawn_score_popup", Vector2(100, 100), 123)), "score-popup pool accepts a test popup")
	popup_motion_session.update(GameSessionScript.SCORE_POPUP_STEP_SECONDS + 0.001)
	var moved_score_popups: Array[Dictionary] = popup_motion_session.visible_score_popups()
	_assert(moved_score_popups.size() == 1, "score popup remains visible after one original drift step")
	if moved_score_popups.size() == 1:
		_assert(moved_score_popups[0]["position"] == Vector2(100, 97), "score popup rises by the original three pixels per update")

	var popup_frame_session = _game_session_from_level(_make_level_from_rows([[1]]))
	popup_frame_session.call("_spawn_score_popup", Vector2(100, 100), 5)
	popup_frame_session.update(GameSessionScript.SCORE_POPUP_FRAME_SECONDS + 0.001)
	var framed_score_popups: Array[Dictionary] = popup_frame_session.visible_score_popups()
	if framed_score_popups.size() == 1:
		_assert(int(framed_score_popups[0]["frame"]) == 1, "score popup advances one DigitsSmall source row after the original 35 ms frame gate")
	popup_frame_session.update(GameSessionScript.SCORE_POPUP_FRAME_SECONDS * GameSessionScript.SCORE_POPUP_FRAME_COUNT)
	_assert(popup_frame_session.visible_score_popups().is_empty(), "score popup expires after the original fifteen-frame animation")

	var popup_y_session = _game_session_from_level(_make_level_from_rows([[1]]))
	popup_y_session.call("_spawn_score_popup", Vector2(10, 11), 5)
	popup_y_session.update(GameSessionScript.SCORE_POPUP_STEP_SECONDS + 0.001)
	_assert(popup_y_session.visible_score_popups().is_empty(), "score popup expires when it crosses the original y cutoff")

	var capped_score_popup_session = _game_session_from_level(_make_level_from_rows([[1]]))
	for score_popup_index in range(GameSessionScript.MAX_SCORE_POPUPS + 5):
		capped_score_popup_session.call("_spawn_score_popup", Vector2(score_popup_index, 100), score_popup_index + 1)
	_assert(capped_score_popup_session.visible_score_popups().size() == GameSessionScript.MAX_SCORE_POPUPS, "score-popup pool keeps the original forty-slot cap")

	var track_session = _game_session_from_level(_make_level_from_rows([[1]]))
	track_session.set_ball_track_rng_seed(1)
	track_session.force_ball(Vector2(300, 200), Vector2.ZERO)
	track_session.update(GameSessionScript.BALL_TRACK_SPAWN_SECONDS)
	_assert(track_session.visible_ball_tracks().is_empty(), "ball tracks wait for the original strict 30 ms spawn gate")
	track_session.update(0.001)
	var tracks: Array[Dictionary] = track_session.visible_ball_tracks()
	_assert(tracks.size() == 1, "ball tracks spawn after the original 30 ms gate")
	if not tracks.is_empty():
		var first_track: Dictionary = tracks[0]
		_assert(int(first_track["frame"]) == 0, "new ball tracks start on frame zero")
		_assert(int(first_track["type_id"]) == GameSessionScript.BALL_TYPE_STANDARD, "standard balls spawn standard track particles")
		var first_track_position: Vector2 = first_track["position"]
		_assert(
			first_track_position.x >= 299.0 and first_track_position.x <= 308.0
				and first_track_position.y >= 199.0 and first_track_position.y <= 208.0,
			"ball track jitter stays in the original ball-centered footprint"
		)
	track_session.call("_advance_ball_track_slots", 0, GameSessionScript.BALL_TRACK_FRAME_SECONDS)
	tracks = track_session.visible_ball_tracks()
	_assert(not tracks.is_empty() and int(tracks[0]["frame"]) == 0, "ball tracks wait for the original strict 30 ms frame gate")
	track_session.call("_advance_ball_track_slots", 0, 0.001)
	tracks = track_session.visible_ball_tracks()
	_assert(not tracks.is_empty() and int(tracks[0]["frame"]) == 1, "ball tracks advance one source frame after the frame gate")
	track_session.call("_advance_ball_track_slots", 0, GameSessionScript.BALL_TRACK_FRAME_SECONDS * GameSessionScript.BALL_TRACK_FRAME_COUNT + 0.001)
	_assert(track_session.visible_ball_tracks().is_empty(), "ball tracks expire after the original twelve-frame animation")

	var capped_track_session = _game_session_from_level(_make_level_from_rows([[1]]))
	capped_track_session.force_ball(Vector2(300, 200), Vector2.ZERO)
	for _track_index in range(GameSessionScript.BALL_TRACK_SLOT_COUNT + 5):
		capped_track_session.call("_spawn_ball_track", 0, capped_track_session.balls[0])
	_assert(capped_track_session.visible_ball_tracks().size() == GameSessionScript.BALL_TRACK_SLOT_COUNT, "ball tracks keep the original fifty-slot cap per ball")

	var fireball_track_session = _game_session_from_level(_make_level_from_rows([[1]]))
	fireball_track_session.force_ball(Vector2(300, 200), Vector2.ZERO, GameSessionScript.BALL_SIZE, GameSessionScript.BALL_TYPE_FIREBALL)
	fireball_track_session.update(GameSessionScript.BALL_TRACK_SPAWN_SECONDS + 0.001)
	var fireball_tracks: Array[Dictionary] = fireball_track_session.visible_ball_tracks()
	_assert(not fireball_tracks.is_empty() and int(fireball_tracks[0]["type_id"]) == GameSessionScript.BALL_TYPE_FIREBALL, "fireballs spawn fireball-colored track particles")

	var non_stricked_track_session = _game_session_from_level(_make_level_from_rows([[1]]))
	non_stricked_track_session.force_ball(Vector2(300, 200), Vector2.ZERO, GameSessionScript.BALL_SIZE, GameSessionScript.BALL_TYPE_NON_STRICKED)
	non_stricked_track_session.update(0.2)
	_assert(non_stricked_track_session.visible_ball_tracks().is_empty(), "non-stricked balls do not generate visible tracks")

	var disabled_track_session = _game_session_from_level(_make_level_from_rows([[1]]))
	disabled_track_session.force_ball(Vector2(300, 200), Vector2.ZERO)
	disabled_track_session.update(GameSessionScript.BALL_TRACK_SPAWN_SECONDS + 0.001)
	_assert(not disabled_track_session.visible_ball_tracks().is_empty(), "ball-track toggle test starts with an active particle")
	disabled_track_session.set_ball_tracks_enabled(false)
	_assert(not disabled_track_session.are_ball_tracks_enabled(), "ball-track toggle disables session-side generation")
	_assert(disabled_track_session.visible_ball_tracks().is_empty(), "disabling ball tracks clears existing particles")
	disabled_track_session.set_ball_tracks_enabled(true)
	disabled_track_session.update(GameSessionScript.BALL_TRACK_SPAWN_SECONDS + 0.001)
	_assert(not disabled_track_session.visible_ball_tracks().is_empty(), "reenabling ball tracks resumes generation")

	var level_ready_session = _game_session_from_level(_make_level_from_rows([[1]]))
	level_ready_session.start_level_ready_sequence()
	_assert(level_ready_session.is_level_ready_sequence_active(), "level-ready sequence starts explicit level-opening timer")
	_assert(level_ready_session.is_level_ready_prompt_visible(), "level-ready sequence starts finite get-ready prompt")
	_assert(not level_ready_session.is_racket_visible(), "level-ready roller hides the racket")
	_assert(not level_ready_session.are_balls_visible(), "level-ready roller hides the ready ball")
	_assert(is_equal_approx(GameSessionScript.RACKET_READY_CENTER_Y, 258.0), "ready racket center matches the original playfield midpoint")
	_assert(is_equal_approx(GameSessionScript.RACKET_READY_DEFAULT_Y, 221.0), "ready racket default top matches the original reset y")
	_assert(is_equal_approx(level_ready_session.racket_rect().position.y, GameSessionScript.RACKET_READY_DEFAULT_Y), "level-ready sequence resets the default racket to the original centered y")
	var ready_racket_y_before_input: float = level_ready_session.racket_rect().position.y
	level_ready_session.move_racket_to(10000.0)
	_assert(is_equal_approx(level_ready_session.racket_rect().position.y, ready_racket_y_before_input), "level-ready roller ignores racket movement before the reveal finishes")
	_assert(GameSessionScript.LEVEL_READY_ROLLER_STEP_SECONDS == 1.0 / GameSessionScript.ORIGINAL_UPDATE_HZ, "level-ready roller advances at the original update cadence")
	_assert(GameSessionScript.LEVEL_READY_ROLLER_STEP_PIXELS == 4.0, "level-ready roller moves by the original four-pixel step")
	_assert(is_equal_approx(GameSessionScript.LEVEL_READY_ANIMATION_SECONDS, 1.9), "level-ready prompt follows the faster original roller travel time")
	_assert(GameSessionScript.LEVEL_READY_ROLLER_SOURCE_SIZE == Vector2(20, 390), "level-ready roller uses the original Roller.tga strip size")
	_assert(GameSessionScript.LEVEL_READY_ROLLER_TRAVEL_PIXELS == 380.0, "level-ready roller travels across the original board width")
	_assert(level_ready_session.level_ready_animation_progress() == 0.0, "level-ready sequence starts its roller animation at the first frame")
	var initial_roller_layout: Dictionary = level_ready_session.level_ready_roller_layout()
	_assert(bool(initial_roller_layout["visible"]), "level-ready sequence exposes the original roller animation")
	_assert(initial_roller_layout["destination"] == Rect2(Vector2(47, 63), Vector2(20, 390)), "level-ready roller starts at the original board edge")
	_assert(initial_roller_layout["source"] == Rect2(Vector2.ZERO, Vector2(20, 390)), "level-ready roller starts from the first original source strip")
	_assert(level_ready_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_LEVEL_READY], "level-ready sequence queues get-ready SFX event")
	var ready_indicators: Array[Dictionary] = level_ready_session.active_bonus_indicators()
	_assert(not ready_indicators.is_empty(), "level-ready sequence exposes original status countdown indicator")
	_assert(int(ready_indicators[0]["icon_index"]) == GameSessionScript.LEVEL_READY_STATUS_ICON_INDEX, "level-ready status indicator uses original level-start icon slot")
	_assert(int(ready_indicators[0]["value"]) == int(GameSessionScript.LEVEL_READY_SEQUENCE_SECONDS), "level-ready status indicator starts at original 30 second count")
	level_ready_session.update(GameSessionScript.LEVEL_READY_ROLLER_STEP_SECONDS)
	var stepped_roller_layout: Dictionary = level_ready_session.level_ready_roller_layout()
	var stepped_roller_destination: Rect2 = stepped_roller_layout["destination"]
	_assert(stepped_roller_destination.position.x == 51.0, "level-ready roller moves by one original four-pixel step")
	_assert(int(stepped_roller_layout["frame"]) == 1, "level-ready roller advances through original source strips")
	level_ready_session.update(1.0 - GameSessionScript.LEVEL_READY_ROLLER_STEP_SECONDS)
	_assert(level_ready_session.is_level_ready_sequence_active(), "level-ready sequence keeps counting while waiting for launch")
	_assert(level_ready_session.level_ready_animation_progress() > 0.0 and level_ready_session.level_ready_animation_progress() < 1.0, "level-ready roller animation advances before launch")
	_assert(level_ready_session.is_level_ready_prompt_visible(), "level-ready prompt stays visible before its original overlay window ends")
	_assert(int(level_ready_session.active_bonus_indicators()[0]["value"]) == 29, "level-ready status indicator counts down once per second")
	level_ready_session.update(GameSessionScript.LEVEL_READY_ANIMATION_SECONDS)
	_assert(level_ready_session.is_level_ready_sequence_active(), "level-ready countdown can continue after get-ready labels disappear")
	_assert(not level_ready_session.is_level_ready_prompt_visible(), "level-ready prompt disappears when its overlay animation finishes")
	_assert(level_ready_session.is_racket_visible(), "racket becomes visible when the roller reveal finishes")
	_assert(level_ready_session.are_balls_visible(), "ready ball becomes visible when the roller reveal finishes")
	_assert(not bool(level_ready_session.level_ready_roller_layout().get("visible", false)), "level-ready roller disappears when it reaches the right side")
	level_ready_session.move_racket_to(10000.0)
	_assert(level_ready_session.racket_rect().end.y == GameSessionScript.RACKET_MAX_BOTTOM, "racket movement resumes after the roller reveal")
	_assert(level_ready_session.launch_ready_ball(), "level-ready ball still launches")
	_assert(not level_ready_session.is_level_ready_sequence_active(), "launch clears level-ready sequence")
	_assert(level_ready_session.pop_audio_events().is_empty(), "initial launch stays silent like the original")

	var skip_ready_session = _game_session_from_level(_make_level_from_rows([[1]]))
	skip_ready_session.start_level_ready_sequence(false)
	var skip_ready_position: Vector2 = skip_ready_session.first_ball_position()
	skip_ready_session.update(GameSessionScript.LEVEL_READY_ROLLER_STEP_SECONDS)
	_assert(not skip_ready_session.launch_ready_ball(), "launch during get-ready only skips the level-start animation")
	_assert(skip_ready_session.state == GameSessionScript.STATE_READY, "get-ready skip keeps the ball in ready state")
	_assert(skip_ready_session.first_ball_velocity().is_zero_approx(), "get-ready skip does not launch the attached ball")
	_assert(skip_ready_session.first_ball_position() == skip_ready_position, "get-ready skip leaves the ready ball attached")
	_assert(skip_ready_session.is_level_ready_sequence_active(), "get-ready skip keeps the original countdown active")
	_assert(not skip_ready_session.is_level_ready_prompt_visible(), "get-ready skip hides the visible roller animation")
	_assert(not bool(skip_ready_session.level_ready_roller_layout().get("visible", false)), "get-ready skip removes the ready roller")
	_assert(skip_ready_session.launch_ready_ball(), "second launch after get-ready skip starts the ball")
	_assert(skip_ready_session.state == GameSessionScript.STATE_PLAYING, "second launch after get-ready skip enters playing state")

	var reset_only_session = _game_session_from_level(_make_level_from_rows([[1]]))
	reset_only_session.reset_round()
	_assert(not reset_only_session.is_level_ready_sequence_active(), "plain round reset does not start level-ready sequence")
	_assert(reset_only_session.pop_audio_events().is_empty(), "plain round reset does not queue get-ready SFX event")

	var auto_launch_session = _game_session_from_level(_make_level_from_rows([[1]]))
	auto_launch_session.start_level_ready_sequence(false)
	var auto_launch_ready_position: Vector2 = auto_launch_session.first_ball_position()
	auto_launch_session.update(GameSessionScript.LEVEL_READY_SEQUENCE_SECONDS - 0.1)
	_assert(auto_launch_session.state == GameSessionScript.STATE_READY, "level-ready timeout does not launch before the original countdown expires")
	_assert(auto_launch_session.first_ball_velocity().is_zero_approx(), "level-ready ball stays attached before timeout")
	_assert(auto_launch_session.is_level_ready_sequence_active(), "level-ready timeout keeps the countdown active until the final tick")
	auto_launch_session.pop_audio_events()
	auto_launch_session.update(0.2)
	_assert(auto_launch_session.state == GameSessionScript.STATE_PLAYING, "level-ready timeout automatically launches the attached ball")
	_assert(not auto_launch_session.is_level_ready_sequence_active(), "automatic ready launch clears the countdown")
	_assert(auto_launch_session.first_ball_velocity().x < 0.0, "automatic ready launch uses the normal original launch vector")
	_assert(auto_launch_session.first_ball_position() == auto_launch_ready_position, "automatic ready launch does not advance the ball during the timeout frame")

	_assert(GameSessionScript.LOW_BLOCK_TIMER_TRIGGER_REQUIRED_BRICKS == 3, "low-block timer starts at the original three-brick threshold")
	_assert(is_equal_approx(GameSessionScript.LOW_BLOCK_TIMER_SECONDS, 30.0), "low-block timer uses the original thirty-second countdown")
	_assert(GameSessionScript.LOW_BLOCK_TIMER_STATUS_ICON_INDEX == 4, "low-block timer uses the original fifth InfoIcons slot")
	_assert(is_equal_approx(GameSessionScript.LOW_BLOCK_TIMER_CHAIN_DELAY_SECONDS, 3.0), "low-block timer uses the original 100 chain ticks")
	var four_block_session = _game_session_from_level(_make_level_from_rows([[1, 1, 1, 1]]))
	four_block_session.force_ball(Vector2(300, 200), Vector2.ZERO)
	four_block_session._monster_spawn_cooldown = 1000.0
	four_block_session._bee_spawn_delay_remaining = 1000.0
	four_block_session.update(0.0)
	_assert(not four_block_session.is_low_block_timer_active(), "low-block timer waits while more than three required bricks remain")

	var low_block_session = _game_session_from_level(_make_level_from_rows([[1, 1, 1]]))
	low_block_session.force_ball(Vector2(300, 200), Vector2.ZERO)
	low_block_session._monster_spawn_cooldown = 1000.0
	low_block_session._bee_spawn_delay_remaining = 1000.0
	low_block_session.update(0.0)
	_assert(low_block_session.is_low_block_timer_active(), "low-block timer arms when only three required bricks remain")
	var low_block_indicator := _indicator_for_icon(low_block_session.active_bonus_indicators(), GameSessionScript.LOW_BLOCK_TIMER_STATUS_ICON_INDEX)
	_assert(not low_block_indicator.is_empty(), "low-block timer exposes original status countdown indicator")
	_assert(int(low_block_indicator["value"]) == 30, "low-block timer starts at the original thirty-second count")
	low_block_session.update(1.0)
	low_block_indicator = _indicator_for_icon(low_block_session.active_bonus_indicators(), GameSessionScript.LOW_BLOCK_TIMER_STATUS_ICON_INDEX)
	_assert(int(low_block_indicator["value"]) == 29, "low-block timer counts down once per second")
	low_block_session.update(GameSessionScript.LOW_BLOCK_TIMER_SECONDS - 1.0)
	_assert(not low_block_session.is_low_block_timer_active(), "low-block timer indicator clears after expiry")
	_assert(_indicator_for_icon(low_block_session.active_bonus_indicators(), GameSessionScript.LOW_BLOCK_TIMER_STATUS_ICON_INDEX).is_empty(), "expired low-block timer hides its status icon")
	_assert(low_block_session.board_state.tile_at(0, 0) == 43, "expired low-block timer rewrites first remaining brick to tile 43")
	_assert(low_block_session.board_state.tile_at(1, 0) == 43, "expired low-block timer rewrites second remaining brick to tile 43")
	_assert(low_block_session.board_state.tile_at(2, 0) == 43, "expired low-block timer rewrites third remaining brick to tile 43")
	_assert(low_block_session.board_state.pending_chain_explosion_count() == 3, "expired low-block timer schedules each rewritten chain tile")
	low_block_session.update(GameSessionScript.LOW_BLOCK_TIMER_CHAIN_DELAY_SECONDS - 0.001)
	_assert(low_block_session.board_state.remaining_required_bricks == 3, "low-block chain tiles wait for the original delayed explosion")
	low_block_session.update(0.002)
	_assert(low_block_session.board_state.remaining_required_bricks == 0, "low-block delayed chain explosions clear the remaining required bricks")
	_assert(low_block_session.state == GameSessionScript.STATE_LEVEL_COMPLETE, "low-block delayed chain explosions can complete the level")

	session.move_racket_to(-100.0)
	_assert(session.racket_rect().position.y == GameSessionScript.RACKET_MIN_Y, "racket clamps to top bound")
	session.move_racket_to(10000.0)
	_assert(session.racket_rect().end.y == GameSessionScript.RACKET_MAX_BOTTOM, "racket clamps to bottom bound")
	_assert(session.first_ball_position().y > session.racket_rect().position.y, "ready ball follows racket")
	_assert(session.launch_ready_ball(), "ready ball launches")
	_assert(session.state == GameSessionScript.STATE_PLAYING, "game session enters playing state")
	var launch_velocity: Vector2 = session.first_ball_velocity()
	var launch_direction := launch_velocity.normalized()
	_assert(launch_velocity.x < 0.0, "launched ball starts toward board")
	_assert(launch_velocity.y > 0.0, "launched ball starts with original downward launch angle")
	_assert(GameSessionScript.DEFAULT_BALL_LAUNCH_TABLE_INDEX == 250, "initial launch preserves original table index")
	_assert(is_equal_approx(launch_direction.x, GameSessionScript.DEFAULT_BALL_LAUNCH_DIRECTION.x), "initial launch uses original x lookup component")
	_assert(is_equal_approx(launch_direction.y, GameSessionScript.DEFAULT_BALL_LAUNCH_DIRECTION.y), "initial launch uses original y lookup component")
	_assert(GameSessionScript.ORIGINAL_DEFAULT_BALL_SPEED_PER_TICK == 2.5, "launched ball uses the faster original default speed tick")
	_assert(is_equal_approx(launch_velocity.length(), 375.0), "launched ball speed matches original default cadence")
	_assert(session.pop_audio_events().is_empty(), "initial ready-ball launch queues no SFX event")
	_assert(GameSessionScript.PROJECTILE_STEP_X == 7.0, "shooting-paddle projectile uses faster parity-tuned step")
	_assert(GameSessionScript.PROJECTILE_SIZE == Vector2(30, 13), "shooting-paddle projectile uses smaller parity-tuned hitbox")
	_assert(GameSessionScript.PROJECTILE_TRAIL_OFFSET == Vector2(26, 0), "shooting-paddle projectile trail stays attached to the native atlas frame")

	var stationary_ball_session = _game_session_from_level(_make_level_from_rows([[1]]))
	stationary_ball_session.force_ball(Vector2(300, 200), Vector2.ZERO)
	var stationary_ball_frame := int(stationary_ball_session.visible_balls()[0].get("frame", 0))
	var stationary_ball_position: Vector2 = stationary_ball_session.first_ball_position()
	stationary_ball_session.update(GameSessionScript.BALL_FRAME_SECONDS)
	_assert(stationary_ball_session.first_ball_position() == stationary_ball_position, "zero-velocity ball remains stationary")
	_assert(
		int(stationary_ball_session.visible_balls()[0].get("frame", 0)) == (stationary_ball_frame + 1) % GameSessionScript.BALL_FRAME_COUNT,
		"zero-velocity active ball keeps animating from the session clock"
	)

	var wall_session = _game_session_from_level(_make_level_from_rows([[1]]))
	wall_session.force_ball(Vector2(300, GameSessionScript.BALL_TOP_Y), Vector2(-80, -120))
	wall_session.update(0.1)
	_assert(wall_session.first_ball_velocity().y > 0.0, "ball bounces off top wall")
	_assert(wall_session.first_ball_position().y == GameSessionScript.BALL_TOP_Y, "top wall clamps ball to original inner boundary")

	var left_wall_session = _game_session_from_level(_make_level_from_rows([[1]]))
	left_wall_session.force_ball(Vector2(GameSessionScript.BALL_LEFT_X, 240), Vector2(-120, 40))
	left_wall_session.update(0.1)
	_assert(left_wall_session.first_ball_velocity().x > 0.0, "ball bounces off left wall")
	_assert(left_wall_session.first_ball_position().x == GameSessionScript.BALL_LEFT_X, "left wall clamps ball to original inner boundary")

	var right_miss_grace_session = _playing_session_from_level(default_level)
	right_miss_grace_session.force_ball(Vector2(PlayfieldSpecScript.WALL_INNER_RIGHT_X + 1.0, 350), Vector2(120, 0))
	right_miss_grace_session.update(0.016)
	_assert(right_miss_grace_session.state == GameSessionScript.STATE_PLAYING, "ball can pass the original right-wall line before being lost")
	_assert(right_miss_grace_session.lives_remaining == GameSessionScript.INITIAL_LIVES, "right-side miss waits for the original screen-edge threshold")
	_assert(GameSessionScript.BALL_LOST_X == 640.0, "ball loss threshold matches original off-screen comparison")

	var speedup_session = _game_session_from_level(_make_level_from_rows([[1]]))
	speedup_session.force_ball(Vector2(500, GameSessionScript.BALL_TOP_Y), Vector2(-300, -1))
	var speedup_ball: Dictionary = speedup_session.balls[0]
	speedup_ball["target_speed"] = 300.0
	speedup_ball["speed_hit_count"] = GameSessionScript.ORIGINAL_BALL_SPEEDUP_HIT_LIMIT
	speedup_session.balls[0] = speedup_ball
	speedup_session.update(0.0)
	var expected_speedup := 300.0 + GameSessionScript.ORIGINAL_BALL_SPEEDUP_PER_TICK * GameSessionScript.ORIGINAL_BALL_STEPS_PER_UPDATE * GameSessionScript.ORIGINAL_UPDATE_HZ
	_assert(is_equal_approx(speedup_session.first_ball_velocity().length(), expected_speedup), "ball speed increases after the original hit-count threshold")
	_assert(int(speedup_session.balls[0]["speed_hit_count"]) == 0, "ball speed-up hit counter resets after acceleration")

	var racket_session = _game_session_from_level(_make_level_from_rows([[1]]))
	racket_session.move_racket_to(220.0)
	var racket_hit_y: float = racket_session.racket_rect().position.y + 40.0
	racket_session.force_ball(
		Vector2(GameSessionScript.RACKET_X - GameSessionScript.BALL_SIZE - 1.0, racket_hit_y),
		Vector2(200, 0)
	)
	racket_session.update(0.1)
	_assert(racket_session.first_ball_velocity().x < 0.0, "ball bounces off racket")
	_assert(is_equal_approx(racket_session.first_ball_velocity().length(), 200.0), "racket bounce preserves forced ball speed")
	_assert(racket_session.current_racket_x() == GameSessionScript.RACKET_X + GameSessionScript.RACKET_HIT_RECOIL_PIXELS, "racket hit kicks the paddle to the original recoil x")
	racket_session.update(GameSessionScript.RACKET_HIT_RECOIL_STEP_SECONDS)
	_assert(racket_session.current_racket_x() == GameSessionScript.RACKET_X + GameSessionScript.RACKET_HIT_RECOIL_PIXELS, "racket recoil waits for the original strict 15 ms gate")
	racket_session.update(0.001)
	_assert(racket_session.current_racket_x() == GameSessionScript.RACKET_X + GameSessionScript.RACKET_HIT_RECOIL_PIXELS - GameSessionScript.RACKET_HIT_RECOIL_STEP_PIXELS, "racket recoil eases back one original pixel after the gate")
	racket_session.update(GameSessionScript.RACKET_HIT_RECOIL_STEP_SECONDS * GameSessionScript.RACKET_HIT_RECOIL_PIXELS + 0.001)
	_assert(racket_session.current_racket_x() == GameSessionScript.RACKET_X, "racket recoil returns to the original resting x")
	var racket_audio_payloads: Array[Dictionary] = racket_session.pop_audio_event_payloads()
	_assert(_payload_events(racket_audio_payloads) == [GameSessionScript.SFX_EVENT_RACKET_BOUNCE], "racket bounce queues semantic SFX event")
	if racket_audio_payloads.size() == 1:
		var racket_bounce_source_x := GameSessionScript.RACKET_X - GameSessionScript.BALL_SIZE
		_assert(is_equal_approx(float(racket_audio_payloads[0].get("source_x", -1.0)), racket_bounce_source_x), "racket bounce SFX payload records the ball source x")
		_assert(is_equal_approx(float(racket_audio_payloads[0].get("pan100", -999.0)), GameSessionScript.sfx_pan100_for_source_x(racket_bounce_source_x)), "racket bounce SFX payload uses the original pan formula")

	var angled_racket_session = _game_session_from_level(_make_level_from_rows([[1]]))
	angled_racket_session.move_racket_to(220.0)
	angled_racket_session.launch_ready_ball()
	var expected_racket_bounce_speed: float = angled_racket_session.first_ball_velocity().length()
	angled_racket_session.pop_audio_events()
	var slowed_racket_ball: Dictionary = angled_racket_session.balls[0]
	slowed_racket_ball["position"] = Vector2(
		GameSessionScript.RACKET_X - GameSessionScript.BALL_SIZE + 1.0,
		angled_racket_session.racket_rect().end.y - GameSessionScript.BALL_SIZE
	)
	slowed_racket_ball["velocity"] = Vector2(12, 0)
	angled_racket_session.balls[0] = slowed_racket_ball
	angled_racket_session.update(0.0)
	_assert(angled_racket_session.first_ball_velocity().x < 0.0, "angled racket hit sends the ball back toward the board")
	_assert(absf(angled_racket_session.first_ball_velocity().y) > 0.0, "angled racket hit changes vertical trajectory")
	_assert(is_equal_approx(angled_racket_session.first_ball_velocity().length(), expected_racket_bounce_speed), "angled racket hit preserves active ball speed")

	var missed_session = _game_session_from_level(_make_level_from_rows([[1]]))
	missed_session.force_ball(Vector2(GameSessionScript.BALL_LOST_X + 1.0, 350), Vector2(120, 0))
	missed_session.update(0.01)
	_assert(missed_session.state == GameSessionScript.STATE_READY, "missed ball resets to ready while spare balls remain")
	_assert(missed_session.lives_remaining == GameSessionScript.INITIAL_LIVES - 1, "missed ball consumes one spare ball")
	_assert(missed_session.active_ball_count() == 1, "missed ball creates a new ready ball")
	_assert(missed_session.is_level_ready_prompt_visible(), "spare-ball miss restarts the original get-ready roller")
	_assert(is_equal_approx(missed_session.racket_rect().position.y, GameSessionScript.RACKET_READY_DEFAULT_Y), "spare-ball miss recenters the racket before relaunch")
	_assert(not missed_session.is_racket_visible(), "spare-ball miss hides the racket while the ready roller plays")
	_assert(not missed_session.are_balls_visible(), "spare-ball miss hides the ready ball while the ready roller plays")
	_assert(bool(missed_session.level_ready_roller_layout()["visible"]), "spare-ball miss exposes the ready roller before relaunch")
	_assert(missed_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_LIFE_LOST], "spare-ball miss queues life-lost SFX event")
	missed_session.update(GameSessionScript.LEVEL_READY_SEQUENCE_SECONDS + 0.1)
	_assert(missed_session.state == GameSessionScript.STATE_PLAYING, "spare-ball ready timeout automatically relaunches the ball")
	_assert(not missed_session.is_level_ready_sequence_active(), "spare-ball automatic relaunch clears the ready countdown")
	_assert(missed_session.first_ball_velocity().x < 0.0, "spare-ball automatic relaunch uses the normal launch vector")
	for miss_index in range(GameSessionScript.INITIAL_LIVES):
		missed_session.force_ball(Vector2(GameSessionScript.BALL_LOST_X + 1.0, 350), Vector2(120, 0))
		missed_session.update(0.01)
	_assert(missed_session.state == GameSessionScript.STATE_GAME_OVER, "losing with zero spare balls enters game over")
	_assert(missed_session.visible_lives() == 0, "game over display clamps spare balls at zero")
	_assert(missed_session.active_ball_count() == 0, "game over hides active balls")
	_assert(not bool(missed_session.level_ready_roller_layout().get("visible", false)), "game over clears any spare-ball ready roller")
	var missed_audio_events: Array[String] = missed_session.pop_audio_events()
	_assert(missed_audio_events.has(GameSessionScript.SFX_EVENT_GAME_OVER), "final miss queues game-over SFX event")

	var brick_session = _game_session_from_level(_make_level_from_rows([[1]]))
	brick_session.force_ball(PlayfieldSpecScript.GRID_ORIGIN + Vector2(2, 2), Vector2(-80, 0))
	brick_session.update(0.01)
	_assert(brick_session.board_state.tile_at(0, 0) == 0, "ball hit clears brick through board state")
	_assert(brick_session.consume_board_changed(), "brick hit marks board for redraw")
	_assert(brick_session.score == GameSessionScript.NORMAL_BRICK_SCORE, "normal brick hit awards original score increment")
	var brick_score_popups: Array[Dictionary] = brick_session.visible_score_popups()
	_assert(brick_score_popups.size() == 1, "normal brick clear spawns original floating score VFX")
	if brick_score_popups.size() == 1:
		_assert(int(brick_score_popups[0]["value"]) == GameSessionScript.NORMAL_BRICK_SCORE, "normal brick score popup uses original five-point value")
		_assert(brick_score_popups[0]["position"] == PlayfieldSpecScript.brick_rect(0, 0).position + GameSessionScript.SCORE_POPUP_BRICK_OFFSET, "normal brick score popup starts at the original brick offset")
	var brick_clear_effects: Array = brick_session.visible_impact_effects()
	_assert(brick_clear_effects.size() == 1, "normal brick clear spawns original clear VFX")
	if brick_clear_effects.size() == 1:
		_assert(int(brick_clear_effects[0]["kind"]) == GameSessionScript.IMPACT_EFFECT_KIND_BRICK_CLEAR, "normal brick clear uses original clear VFX column")
		_assert(brick_clear_effects[0]["position"] == PlayfieldSpecScript.brick_rect(0, 0).position, "normal brick clear VFX starts at brick origin")
	var brick_audio_events: Array[String] = brick_session.pop_audio_events()
	_assert(brick_audio_events.has(GameSessionScript.SFX_EVENT_BRICK_CLEAR), "brick clear queues IDA-backed SFX event")
	_assert(brick_audio_events.has(GameSessionScript.SFX_EVENT_LEVEL_COMPLETE), "final brick clear queues level-complete SFX event")
	for catchup_index in range(6):
		brick_session.update(0.0)
	_assert(brick_session.displayed_score == GameSessionScript.NORMAL_BRICK_SCORE, "displayed score catches up gradually")
	_assert(brick_session.state == GameSessionScript.STATE_LEVEL_COMPLETE, "clearing final required brick completes level")

	var hard_session = _game_session_from_level(_make_level_from_rows([[8, 1]]))
	hard_session.force_ball(PlayfieldSpecScript.GRID_ORIGIN + Vector2(2, 2), Vector2(-80, 0))
	hard_session.update(0.01)
	_assert(hard_session.board_state.tile_at(0, 0) == 8, "ordinary ball hit leaves force-break-only brick intact")
	_assert(not hard_session.consume_board_changed(), "ordinary hard-brick hit does not redraw board")
	_assert(hard_session.score == 0, "ordinary hard-brick hit awards no score")
	_assert(hard_session.state == GameSessionScript.STATE_PLAYING, "hard-brick hit does not complete while required bricks remain")

	var wall_vfx_level := _make_level_from_rows([[], [], [], [], [], [], [], [], [], [], [], [], [1]])
	var fireball_left_wall_session = _playing_session_from_level(wall_vfx_level)
	fireball_left_wall_session.force_ball(
		Vector2(GameSessionScript.BALL_LEFT_X - 1.0, 200.0),
		Vector2(-80, 0),
		GameSessionScript.BALL_SIZE,
		GameSessionScript.BALL_TYPE_FIREBALL
	)
	fireball_left_wall_session.update(0.0)
	var left_wall_effects: Array = fireball_left_wall_session.visible_impact_effects()
	_assert(left_wall_effects.size() == 1, "fireball left-wall hit spawns original explosion VFX")
	if left_wall_effects.size() == 1:
		_assert(int(left_wall_effects[0]["kind"]) == GameSessionScript.IMPACT_EFFECT_KIND_EXPLOSION, "fireball left-wall VFX uses the shared original explosion kind")
		_assert(
			left_wall_effects[0]["position"] == Vector2(
				GameSessionScript.BALL_LEFT_X,
				200.0 + GameSessionScript.BALL_SIZE * 0.5
			) + GameSessionScript.FIREBALL_WALL_IMPACT_OFFSET,
			"fireball left-wall VFX uses the original wall-impact offset"
		)

	var fireball_corner_wall_session = _playing_session_from_level(wall_vfx_level)
	fireball_corner_wall_session.force_ball(
		Vector2(GameSessionScript.BALL_LEFT_X - 1.0, GameSessionScript.BALL_TOP_Y - 1.0),
		Vector2(-80, -80),
		GameSessionScript.BALL_SIZE,
		GameSessionScript.BALL_TYPE_FIREBALL
	)
	fireball_corner_wall_session.update(0.0)
	var corner_wall_effects: Array = fireball_corner_wall_session.visible_impact_effects()
	_assert(corner_wall_effects.size() == 1, "fireball corner wall hit spawns only one wall VFX")
	if corner_wall_effects.size() == 1:
		_assert(
			corner_wall_effects[0]["position"] == Vector2(
				GameSessionScript.BALL_LEFT_X,
				GameSessionScript.BALL_TOP_Y + GameSessionScript.BALL_SIZE * 0.5
			) + GameSessionScript.FIREBALL_WALL_IMPACT_OFFSET,
			"fireball corner wall VFX prioritizes the original left-wall position"
		)

	var fireball_top_wall_session = _playing_session_from_level(wall_vfx_level)
	fireball_top_wall_session.force_ball(
		Vector2(200.0, GameSessionScript.BALL_TOP_Y - 1.0),
		Vector2(0, -80),
		GameSessionScript.BALL_SIZE,
		GameSessionScript.BALL_TYPE_FIREBALL
	)
	fireball_top_wall_session.update(0.0)
	var top_wall_effects: Array = fireball_top_wall_session.visible_impact_effects()
	_assert(top_wall_effects.size() == 1, "fireball top-wall hit spawns original explosion VFX")
	if top_wall_effects.size() == 1:
		_assert(
			top_wall_effects[0]["position"] == Vector2(
				200.0 + GameSessionScript.BALL_SIZE * 0.5,
				GameSessionScript.BALL_TOP_Y
			) + GameSessionScript.FIREBALL_WALL_IMPACT_OFFSET,
			"fireball top-wall VFX uses the original wall-impact offset"
		)

	var fireball_bottom_wall_session = _playing_session_from_level(wall_vfx_level)
	fireball_bottom_wall_session.force_ball(
		Vector2(200.0, GameSessionScript.BALL_BOTTOM_Y - GameSessionScript.BALL_SIZE + 1.0),
		Vector2(0, 80),
		GameSessionScript.BALL_SIZE,
		GameSessionScript.BALL_TYPE_FIREBALL
	)
	fireball_bottom_wall_session.update(0.0)
	var bottom_wall_effects: Array = fireball_bottom_wall_session.visible_impact_effects()
	_assert(bottom_wall_effects.size() == 1, "fireball bottom-wall hit spawns original explosion VFX")
	if bottom_wall_effects.size() == 1:
		_assert(
			bottom_wall_effects[0]["position"] == Vector2(
				200.0 + GameSessionScript.BALL_SIZE * 0.5,
				GameSessionScript.BALL_BOTTOM_Y
			) + GameSessionScript.FIREBALL_WALL_IMPACT_OFFSET,
			"fireball bottom-wall VFX uses the original wall-impact offset"
		)

	var fireball_back_wall_session = _playing_session_from_level(wall_vfx_level)
	fireball_back_wall_session.back_wall_time_remaining = GameSessionScript.BACK_WALL_DURATION_SECONDS
	fireball_back_wall_session.force_ball(
		Vector2(GameSessionScript.BACK_WALL_BOUNCE_X - GameSessionScript.BALL_SIZE + 1.0, 200.0),
		Vector2(80, 0),
		GameSessionScript.BALL_SIZE,
		GameSessionScript.BALL_TYPE_FIREBALL
	)
	fireball_back_wall_session.update(0.0)
	var back_wall_effects: Array = fireball_back_wall_session.visible_impact_effects()
	_assert(back_wall_effects.size() == 1, "fireball active-back-wall hit spawns original explosion VFX")
	if back_wall_effects.size() == 1:
		_assert(
			back_wall_effects[0]["position"] == Vector2(
				GameSessionScript.BACK_WALL_BOUNCE_X,
				200.0 + GameSessionScript.BALL_SIZE * 0.5
			) + GameSessionScript.FIREBALL_WALL_IMPACT_OFFSET,
			"fireball active-back-wall VFX uses the original wall-impact offset"
		)

	var standard_wall_session = _playing_session_from_level(wall_vfx_level)
	standard_wall_session.force_ball(
		Vector2(GameSessionScript.BALL_LEFT_X - 1.0, 200.0),
		Vector2(-80, 0)
	)
	standard_wall_session.update(0.0)
	_assert(standard_wall_session.visible_impact_effects().is_empty(), "standard wall hit does not spawn fireball wall VFX")

	var fireball_right_miss_session = _playing_session_from_level(wall_vfx_level)
	fireball_right_miss_session.force_ball(
		Vector2(GameSessionScript.BALL_LOST_X + 1.0, 200.0),
		Vector2(80, 0),
		GameSessionScript.BALL_SIZE,
		GameSessionScript.BALL_TYPE_FIREBALL
	)
	fireball_right_miss_session.update(0.0)
	_assert(fireball_right_miss_session.visible_impact_effects().is_empty(), "fireball right-side miss without back wall does not spawn wall VFX")

	var downgrade_session = _game_session_from_level(_make_level_from_rows([[15, 42, 70, 1]]))
	var downgrade_15: Dictionary = downgrade_session._resolve_board_tile_hit(0, 0, 15)
	downgrade_session._apply_board_hit_result(downgrade_15)
	_assert(downgrade_session.board_state.tile_at(0, 0) == 14, "tile 15 downgrades instead of clearing on ordinary hit")
	_assert(downgrade_session.score == GameSessionScript.NORMAL_BRICK_SCORE, "downgrade hit awards original score increment")
	var downgrade_42: Dictionary = downgrade_session._resolve_board_tile_hit(1, 0, 42)
	downgrade_session._apply_board_hit_result(downgrade_42)
	_assert(downgrade_session.board_state.tile_at(1, 0) == 44, "tile 42 downgrades to original animated next stage")
	var downgrade_70: Dictionary = downgrade_session._resolve_board_tile_hit(2, 0, 70)
	downgrade_session._apply_board_hit_result(downgrade_70)
	_assert(downgrade_session.board_state.tile_at(2, 0) == 90, "tile 70 downgrades to original high-range next stage")
	_assert(downgrade_session.score == GameSessionScript.NORMAL_BRICK_SCORE * 3, "each downgrade hit awards original score increment")

	var chain_session = _game_session_from_level(_make_level_from_rows([[43, 68]]))
	chain_session.force_ball(PlayfieldSpecScript.GRID_ORIGIN + Vector2(2, 2), Vector2(-80, 0))
	chain_session.update(0.01)
	_assert(chain_session.board_state.tile_at(0, 0) == 0, "chain tile hit clears source tile")
	_assert(chain_session.board_state.tile_at(1, 0) == 68, "chain tile hit leaves neighbor pending")
	_assert(chain_session.board_state.pending_chain_explosion_count() == 1, "chain tile hit schedules delayed neighbor")
	_assert(chain_session.score == GameSessionScript.BRICK_SCORE, "chain hit scores immediate cleared tile")
	var immediate_chain_popups: Array[Dictionary] = chain_session.visible_score_popups()
	_assert(immediate_chain_popups.size() == 1, "chain tile hit spawns immediate score-popup VFX")
	if immediate_chain_popups.size() == 1:
		_assert(int(immediate_chain_popups[0]["value"]) == GameSessionScript.CHAIN_BRICK_SCORE, "chain score popup uses original fifteen-point value")
		_assert(immediate_chain_popups[0]["position"] == PlayfieldSpecScript.brick_rect(0, 0).position + GameSessionScript.SCORE_POPUP_CHAIN_OFFSET, "chain score popup starts at original chain offset")
	var immediate_chain_effects: Array = chain_session.visible_impact_effects()
	_assert(immediate_chain_effects.size() == 1, "chain tile hit spawns immediate board impact VFX")
	if immediate_chain_effects.size() == 1:
		_assert(int(immediate_chain_effects[0]["kind"]) == GameSessionScript.IMPACT_EFFECT_KIND_CHAIN_EXPLOSION, "chain tile VFX uses the shared original explosion kind")
		_assert(immediate_chain_effects[0]["position"] == PlayfieldSpecScript.brick_rect(0, 0).position + GameSessionScript.CHAIN_EXPLOSION_IMPACT_OFFSET, "chain tile VFX uses the original brick impact offset")
	_assert(chain_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_CHAIN_EXPLOSION], "chain tile hit queues chain-explosion SFX event")
	chain_session.update(0.031)
	_assert(chain_session.board_state.tile_at(1, 0) == 0, "delayed chain explosion clears neighbor")
	_assert(chain_session.score == GameSessionScript.BRICK_SCORE * 2, "delayed chain explosion awards score")
	_assert(chain_session.state == GameSessionScript.STATE_LEVEL_COMPLETE, "chain explosion can complete level")
	var delayed_chain_popups: Array[Dictionary] = chain_session.visible_score_popups()
	_assert(delayed_chain_popups.size() == 2, "delayed chain clear adds a second score-popup VFX")
	if delayed_chain_popups.size() == 2:
		_assert(delayed_chain_popups[1]["position"] == PlayfieldSpecScript.brick_rect(1, 0).position + GameSessionScript.SCORE_POPUP_CHAIN_OFFSET, "delayed chain score popup uses original chain offset")
	var delayed_chain_effects: Array = chain_session.visible_impact_effects()
	_assert(delayed_chain_effects.size() == 2, "delayed chain clear adds a second board impact VFX")
	if delayed_chain_effects.size() == 2:
		_assert(delayed_chain_effects[1]["position"] == PlayfieldSpecScript.brick_rect(1, 0).position + GameSessionScript.CHAIN_EXPLOSION_IMPACT_OFFSET, "delayed chain VFX uses the fired brick position")
	var delayed_chain_audio_events: Array[String] = chain_session.pop_audio_events()
	_assert(delayed_chain_audio_events.has(GameSessionScript.SFX_EVENT_CHAIN_EXPLOSION), "delayed chain clear queues chain-explosion SFX event")
	_assert(delayed_chain_audio_events.has(GameSessionScript.SFX_EVENT_LEVEL_COMPLETE), "delayed chain clear queues level-complete SFX event")

	var projectile_chain_session = _playing_session_from_level(_make_level_from_rows([[43]]))
	var projectile_chain_projectiles: Array[Dictionary] = [_projectile(
		GameSessionScript.PROJECTILE_TYPE_CONTINUOUS,
		PlayfieldSpecScript.GRID_ORIGIN + Vector2(7, 1)
	)]
	projectile_chain_session.projectiles = projectile_chain_projectiles
	projectile_chain_session.update(0.0)
	_assert(projectile_chain_session.board_state.tile_at(0, 0) == 0, "projectile hit clears chain tile through shared board hit routing")
	_assert(projectile_chain_session.active_projectile_count() == 0, "projectile is consumed by chain board hit")
	var projectile_chain_effects: Array = projectile_chain_session.visible_impact_effects()
	_assert(projectile_chain_effects.size() == 1, "projectile-triggered chain clear spawns board impact VFX")
	if projectile_chain_effects.size() == 1:
		_assert(int(projectile_chain_effects[0]["kind"]) == GameSessionScript.IMPACT_EFFECT_KIND_CHAIN_EXPLOSION, "projectile-triggered chain VFX uses the shared original explosion kind")

	var bonus_life_session = _game_session_from_level(_make_level_from_rows([[1]]))
	bonus_life_session.award_score(GameSessionScript.EXTRA_LIFE_SCORE_STEP - GameSessionScript.BRICK_SCORE)
	_assert(bonus_life_session.lives_remaining == GameSessionScript.INITIAL_LIVES, "extra life waits for threshold")
	bonus_life_session.award_score(GameSessionScript.BRICK_SCORE)
	_assert(bonus_life_session.lives_remaining == GameSessionScript.INITIAL_LIVES + 1, "extra life is awarded at original threshold")
	_assert(bonus_life_session.points_to_next_extra_life == GameSessionScript.EXTRA_LIFE_SCORE_STEP * 2, "extra life threshold advances")

	var advance_session = _game_session_from_level(_make_level_from_rows([[1]]))
	advance_session.award_score(30)
	advance_session.lives_remaining = 2
	advance_session.advance_to_level(_make_level_from_rows([[2]]), 15)
	_assert(advance_session.score == 30, "level advance preserves run score")
	_assert(advance_session.lives_remaining == 2, "level advance preserves spare balls")
	_assert(advance_session.display_level_number == 15, "level advance preserves displayed level")
	_assert(advance_session.state == GameSessionScript.STATE_READY, "level advance resets round to ready")

	var bonus_spawn_session = _game_session_from_level(_make_level_from_rows([[1]], _make_bonus_tail([1])))
	bonus_spawn_session.set_bonus_rng_seed(17)
	bonus_spawn_session.force_bonus_drop_ready()
	bonus_spawn_session.force_ball(PlayfieldSpecScript.GRID_ORIGIN + Vector2(2, 2), Vector2(-80, 0))
	bonus_spawn_session.update(0.01)
	_assert(bonus_spawn_session.board_state.tile_at(0, 0) == 0, "bonus-eligible brick hit still clears the source tile")
	_assert(bonus_spawn_session.score == GameSessionScript.NORMAL_BRICK_SCORE, "bonus-eligible brick hit still awards normal brick score")
	_assert(bonus_spawn_session.remaining_bonus_stock == 0, "bonus spawn consumes one original stock counter")
	_assert(bonus_spawn_session.bonus_stock_counts[0] == 0, "bonus spawn decrements selected stock")
	var spawned_bonuses: Array = bonus_spawn_session.visible_falling_bonuses()
	_assert(spawned_bonuses.size() == 1, "eligible brick hit can spawn a falling bonus")
	if spawned_bonuses.size() == 1:
		_assert(int(spawned_bonuses[0]["type_id"]) == 0, "spawned bonus keeps selected original type")
		_assert(spawned_bonuses[0]["position"] == PlayfieldSpecScript.GRID_ORIGIN, "spawned bonus starts at source brick position")
	var bonus_spawn_effects: Array = bonus_spawn_session.visible_impact_effects()
	_assert(bonus_spawn_effects.size() == 1, "bonus-spawning brick clear creates original bonus-clear VFX")
	if bonus_spawn_effects.size() == 1:
		_assert(int(bonus_spawn_effects[0]["kind"]) == GameSessionScript.IMPACT_EFFECT_KIND_BONUS_BRICK_CLEAR, "bonus-spawning brick clear uses original bonus-clear VFX column")
		_assert(bonus_spawn_effects[0]["position"] == PlayfieldSpecScript.brick_rect(0, 0).position, "bonus-spawning brick clear VFX starts at brick origin")
	var bonus_spawn_audio_payloads: Array[Dictionary] = bonus_spawn_session.pop_audio_event_payloads()
	_assert(_payload_events(bonus_spawn_audio_payloads).has(GameSessionScript.SFX_EVENT_BONUS_SPAWN), "bonus spawn queues semantic SFX event")
	for payload: Dictionary in bonus_spawn_audio_payloads:
		if String(payload.get("event", "")) == GameSessionScript.SFX_EVENT_BONUS_SPAWN:
			_assert(is_equal_approx(float(payload.get("pan100", -999.0)), GameSessionScript.sfx_pan100_for_source_x(PlayfieldSpecScript.GRID_ORIGIN.x)), "bonus-spawn SFX payload uses source brick x")

	var moving_bonus_session = _game_session_from_level(_make_level_from_rows([[1]]))
	var moving_bonuses: Array[Dictionary] = [{
		"active": true,
		"type_id": 2,
		"position": Vector2(100, 100),
		"base_y": 100.0,
		"angle": 0,
		"frame": 0,
		"frame_elapsed": 0.0,
	}]
	moving_bonus_session.falling_bonuses = moving_bonuses
	moving_bonus_session.force_ball(Vector2(300, 200), Vector2.ZERO)
	moving_bonus_session.update(0.1)
	var moved_bonuses: Array = moving_bonus_session.visible_falling_bonuses()
	_assert(moved_bonuses.size() == 1, "falling bonus remains active while in bounds")
	if moved_bonuses.size() == 1:
		_assert(is_equal_approx(moved_bonuses[0]["position"].x, 122.5), "falling bonus advances by original three-substep x speed")
		_assert(int(moved_bonuses[0]["angle"]) == 45, "falling bonus advances by original three-substep angle speed")
		_assert(int(moved_bonuses[0]["frame"]) == 1, "falling bonus animation advances at original cadence")

	var stepped_bonus_session = _game_session_from_level(_make_level_from_rows([[1]]))
	var stepped_bonuses: Array[Dictionary] = [{
		"active": true,
		"type_id": 2,
		"position": Vector2(100, 100),
		"base_y": 100.0,
		"angle": 0,
		"frame": 0,
		"frame_elapsed": 0.0,
	}]
	stepped_bonus_session.falling_bonuses = stepped_bonuses
	stepped_bonus_session.force_ball(Vector2(300, 200), Vector2.ZERO)
	for _step in range(10):
		stepped_bonus_session.update(0.01)
	var stepped_moved_bonuses: Array = stepped_bonus_session.visible_falling_bonuses()
	_assert(stepped_moved_bonuses.size() == 1, "falling bonus remains active across split updates")
	if moved_bonuses.size() == 1 and stepped_moved_bonuses.size() == 1:
		_assert(is_equal_approx(stepped_moved_bonuses[0]["position"].x, moved_bonuses[0]["position"].x), "falling bonus speed is frame-rate independent")
		_assert(int(stepped_moved_bonuses[0]["angle"]) == int(moved_bonuses[0]["angle"]), "falling bonus wave angle is frame-rate independent")

	var expired_bonus_session = _game_session_from_level(_make_level_from_rows([[1]]))
	var expiring_bonuses: Array[Dictionary] = [{
		"active": true,
		"type_id": 2,
		"position": Vector2(GameSessionScript.BONUS_EXPIRE_X - 1.0, 100),
		"base_y": 100.0,
		"angle": 0,
		"frame": 0,
		"frame_elapsed": 0.0,
	}]
	expired_bonus_session.falling_bonuses = expiring_bonuses
	expired_bonus_session.force_ball(Vector2(300, 200), Vector2.ZERO)
	expired_bonus_session.update(1.0 / GameSessionScript.ORIGINAL_BONUS_SUBSTEP_HZ)
	_assert(expired_bonus_session.visible_falling_bonuses().is_empty(), "falling bonus expires beyond the original x bound")
	_assert(expired_bonus_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_BONUS_EXPIRE], "falling bonus expiry queues original semantic SFX event")

	var collect_session = _game_session_from_level(_make_level_from_rows([[1]]))
	collect_session.move_racket_to(220.0)
	var collect_bonuses: Array[Dictionary] = [{
		"active": true,
		"type_id": 2,
		"position": Vector2(GameSessionScript.RACKET_X - 5.0, collect_session.racket_rect().position.y + 20.0),
		"base_y": collect_session.racket_rect().position.y + 20.0,
		"angle": 0,
		"frame": 0,
		"frame_elapsed": 0.0,
	}]
	collect_session.falling_bonuses = collect_bonuses
	collect_session.force_ball(Vector2(300, 200), Vector2.ZERO)
	collect_session.update(0.01)
	_assert(collect_session.visible_falling_bonuses().is_empty(), "racket collects overlapping falling bonus")
	_assert(collect_session.bonus_stack_entries().size() == 1, "collected bonus enters stack")
	_assert(int(collect_session.bonus_stack_entries()[0]["type_id"]) == 2, "stack preserves collected bonus type")
	_assert(collect_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_BONUS_COLLECT], "bonus collection queues semantic SFX event")

	var full_stack_session = _game_session_from_level(_make_level_from_rows([[1]]))
	full_stack_session.move_racket_to(220.0)
	for stack_index in range(GameSessionScript.MAX_STACKED_BONUSES):
		full_stack_session.bonus_stack.append({
			"type_id": stack_index % GameSessionScript.BONUS_TYPE_COUNT,
			"frame": 0,
			"frame_elapsed": 0.0,
		})
	var full_stack_bonuses: Array[Dictionary] = [{
		"active": true,
		"type_id": 3,
		"position": Vector2(GameSessionScript.RACKET_X - 5.0, full_stack_session.racket_rect().position.y + 20.0),
		"base_y": full_stack_session.racket_rect().position.y + 20.0,
		"angle": 0,
		"frame": 0,
		"frame_elapsed": 0.0,
	}]
	full_stack_session.falling_bonuses = full_stack_bonuses
	full_stack_session.force_ball(Vector2(300, 200), Vector2.ZERO)
	full_stack_session.update(0.01)
	_assert(full_stack_session.bonus_stack_entries().size() == GameSessionScript.MAX_STACKED_BONUSES, "bonus stack enforces original cap")
	_assert(full_stack_session.visible_falling_bonuses().size() == 1, "full stack does not consume overlapping falling bonus")

	var debug_stack_session = _game_session_from_level(_make_level_from_rows([[1]]))
	var invalid_debug_add: Dictionary = debug_stack_session.debug_add_bonus_to_stack(-1)
	_assert(invalid_debug_add["status"] == "invalid", "debug bonus stack rejects invalid type IDs")
	var debug_add: Dictionary = debug_stack_session.debug_add_bonus_to_stack(GameSessionScript.BONUS_EXTRA_LIFE)
	_assert(debug_add["status"] == "added", "debug bonus stack can add an item")
	_assert(int(debug_stack_session.bonus_stack_entries()[0]["type_id"]) == GameSessionScript.BONUS_EXTRA_LIFE, "debug-added item keeps requested type")
	var debug_remove_invalid: Dictionary = debug_stack_session.debug_remove_bonus_from_stack(4)
	_assert(debug_remove_invalid["status"] == "invalid", "debug bonus stack rejects invalid remove indexes")
	var debug_remove: Dictionary = debug_stack_session.debug_remove_bonus_from_stack(0)
	_assert(debug_remove["status"] == "removed", "debug bonus stack can remove an item")
	_assert(debug_stack_session.bonus_stack_entries().is_empty(), "debug remove updates bonus stack")
	debug_stack_session.debug_add_bonus_to_stack(GameSessionScript.BONUS_ADD_FIREBALL)
	debug_stack_session.debug_add_bonus_to_stack(GameSessionScript.BONUS_JUMP_TO_NEXT_LEVEL)
	_assert(debug_stack_session.debug_clear_bonus_stack() == 2, "debug clear reports removed stack count")
	_assert(debug_stack_session.bonus_stack_entries().is_empty(), "debug clear empties bonus stack")
	for debug_index in range(GameSessionScript.MAX_STACKED_BONUSES):
		_assert(debug_stack_session.debug_add_bonus_to_stack(debug_index % GameSessionScript.BONUS_TYPE_COUNT)["status"] == "added", "debug add fills stack")
	var debug_full_result: Dictionary = debug_stack_session.debug_add_bonus_to_stack(GameSessionScript.BONUS_EXTRA_LIFE)
	_assert(debug_full_result["status"] == "full", "debug bonus stack reports full capacity")
	_assert(debug_stack_session.bonus_stack_entries().size() == GameSessionScript.MAX_STACKED_BONUSES, "debug add does not overflow stack")

	var chain_selector_session = _game_session_from_level(_make_level_from_rows([[1]], _make_bonus_tail([1])))
	chain_selector_session.set_bonus_rng_seed(23)
	chain_selector_session.force_bonus_drop_ready()
	chain_selector_session.force_ball(PlayfieldSpecScript.GRID_ORIGIN + Vector2(2, 2), Vector2(-80, 0))
	chain_selector_session.update(0.01)
	_assert(chain_selector_session.board_state.tile_at(0, 0) == 68, "random bonus selector can convert a hit brick into a chain tile")
	_assert(chain_selector_session.board_state.pending_chain_explosion_count() == 1, "converted random chain tile is scheduled")
	_assert(chain_selector_session.score == GameSessionScript.NORMAL_BRICK_SCORE, "converted chain selector still scores the normal brick hit")
	var chain_selector_effects: Array = chain_selector_session.visible_impact_effects()
	_assert(chain_selector_effects.size() == 1, "converted random chain selector creates original bonus-clear VFX")
	if chain_selector_effects.size() == 1:
		_assert(int(chain_selector_effects[0]["kind"]) == GameSessionScript.IMPACT_EFFECT_KIND_BONUS_BRICK_CLEAR, "converted random chain selector uses original bonus-clear VFX column")
	chain_selector_session.update(0.031)
	_assert(chain_selector_session.board_state.tile_at(0, 0) == 0, "converted chain tile clears after delay")
	_assert(chain_selector_session.score == GameSessionScript.NORMAL_BRICK_SCORE + GameSessionScript.BRICK_SCORE, "converted chain explosion awards chain clear score")
	var delayed_chain_selector_effects: Array = chain_selector_session.visible_impact_effects()
	_assert(delayed_chain_selector_effects.size() == 2, "converted chain selector keeps clear VFX and adds delayed chain VFX")
	if delayed_chain_selector_effects.size() == 2:
		_assert(int(delayed_chain_selector_effects[0]["kind"]) == GameSessionScript.IMPACT_EFFECT_KIND_BONUS_BRICK_CLEAR, "converted chain selector keeps the original clear VFX")
		_assert(int(delayed_chain_selector_effects[1]["kind"]) == GameSessionScript.IMPACT_EFFECT_KIND_CHAIN_EXPLOSION, "converted chain selector delayed clear adds chain explosion VFX")

	var inactive_bonus_session = _game_session_from_level(_make_level_from_rows([[1]]))
	_stack_bonus(inactive_bonus_session, GameSessionScript.BONUS_EXTRA_LIFE)
	var inactive_bonus_result: Dictionary = inactive_bonus_session.activate_next_bonus()
	_assert(inactive_bonus_result["status"] == "inactive", "bonus activation waits for playing state")
	_assert(inactive_bonus_session.bonus_stack_entries().size() == 1, "inactive bonus activation preserves stack")

	var empty_bonus_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	var empty_bonus_result: Dictionary = empty_bonus_session.activate_next_bonus()
	_assert(empty_bonus_result["status"] == "empty", "empty bonus stack reports empty activation")

	var unsupported_bonus_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	_stack_bonus(unsupported_bonus_session, 99)
	var unsupported_bonus_result: Dictionary = unsupported_bonus_session.activate_next_bonus()
	_assert(unsupported_bonus_result["status"] == "unsupported", "unsupported bonus reports explicit status")
	_assert(unsupported_bonus_session.bonus_stack_entries().size() == 1, "unsupported bonus remains stacked")

	var repeated_unsupported_result: Dictionary = unsupported_bonus_session.activate_next_bonus()
	_assert(repeated_unsupported_result["status"] == "unsupported", "unsupported bonus remains first after rejected activation")

	var one_shot_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	_stack_bonus(one_shot_session, GameSessionScript.BONUS_SHOOTING_PADDLE_TIMED)
	var one_shot_result: Dictionary = one_shot_session.activate_next_bonus()
	_assert(one_shot_result["status"] == "applied", "one-shot shooting bonus applies")
	_assert(one_shot_result["effect"] == "shooting_paddle_one_shot", "one-shot shooting bonus reports effect")
	_assert(bool(one_shot_result["armed"]), "one-shot shooting bonus arms the original launcher")
	_assert(one_shot_session.active_projectile_count() == 0, "one-shot shooting bonus waits for explicit right-click fire")
	_assert(not one_shot_session.is_shooting_paddle_active(), "one-shot shooting bonus does not leave continuous shooting armed")
	_assert(one_shot_session.is_single_shot_paddle_armed(), "one-shot shooting bonus keeps one projectile armed")
	_assert(one_shot_session.current_racket_visual_mode() == GameSessionScript.RACKET_VISUAL_MODE_SHOOTING_ONE_SHOT, "one-shot shooting bonus switches racket to original single-shot insert")
	_assert(one_shot_session.current_racket_visual_frame() == 0, "one-shot launcher starts at first original frame")
	_assert(one_shot_session.bonus_stack_entries().is_empty(), "one-shot shooting bonus consumes first stack entry")
	var one_shot_audio_events: Array[String] = one_shot_session.pop_audio_events()
	_assert(not one_shot_audio_events.has(GameSessionScript.SFX_EVENT_PROJECTILE_FIRE), "one-shot shooting activation does not queue projectile-fire SFX event")
	_assert(one_shot_audio_events.has(GameSessionScript.SFX_EVENT_BONUS_APPLY), "one-shot shooting queues bonus-apply SFX event")
	one_shot_session._monster_spawn_cooldown = 999.0
	one_shot_session.update(GameSessionScript.RACKET_VISUAL_FRAME_SECONDS)
	_assert(one_shot_session.current_racket_visual_frame() == 1, "one-shot launcher advances through original 50 ms frames")
	one_shot_session.update(GameSessionScript.RACKET_VISUAL_FRAME_SECONDS * 3.0)
	_assert(one_shot_session.current_racket_visual_frame() == GameSessionScript.RACKET_VISUAL_MAX_FRAME, "one-shot launcher reaches original final frame")
	var one_shot_fire_result: Dictionary = one_shot_session.fire_shooting_paddle()
	_assert(one_shot_fire_result["status"] == "fired", "right-click fire shoots armed one-shot projectile")
	_assert(one_shot_fire_result["projectile_type"] == GameSessionScript.PROJECTILE_TYPE_STRONG, "one-shot fire uses original strong projectile")
	_assert(one_shot_session.active_projectile_count() == 1, "right-click fire exposes one spawned projectile")
	_assert(not one_shot_session.is_single_shot_paddle_armed(), "one-shot fire consumes the armed projectile")
	var one_shot_projectiles: Array = one_shot_session.visible_projectiles()
	var expected_projectile_start := Vector2(
		GameSessionScript.RACKET_X - 20.0,
		one_shot_session.racket_rect().position.y + floorf((GameSessionScript.RACKET_SEGMENT_PIXEL_STEP * float(one_shot_session.racket_segment_count) + 9.0) * 0.5) - 1.0
	)
	if one_shot_projectiles.size() == 1:
		_assert(
			one_shot_session.projectile_rect(one_shot_projectiles[0]) == Rect2(expected_projectile_start, GameSessionScript.PROJECTILE_SIZE),
			"one-shot projectile starts at IDA-backed paddle muzzle"
		)
	var one_shot_fire_audio_events: Array[String] = one_shot_session.pop_audio_events()
	_assert(one_shot_fire_audio_events.has(GameSessionScript.SFX_EVENT_PROJECTILE_FIRE), "right-click fire queues projectile-fire SFX event")
	one_shot_session.update(GameSessionScript.RACKET_VISUAL_FRAME_SECONDS * 4.0)
	_assert(one_shot_session.current_racket_visual_mode() == GameSessionScript.RACKET_VISUAL_MODE_NORMAL, "one-shot launcher retracts to normal insert after firing")
	_assert(one_shot_session.current_racket_visual_frame() == 0, "one-shot launcher retracts through original frames")
	one_shot_session.update(0.01)
	one_shot_projectiles = one_shot_session.visible_projectiles()
	if one_shot_projectiles.size() == 1:
		_assert(one_shot_projectiles[0]["position"] == expected_projectile_start + Vector2(-GameSessionScript.PROJECTILE_STEP_X * 2.0, 0), "projectile advances left by original step")

	var continuous_shooting_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	_stack_bonus(continuous_shooting_session, GameSessionScript.BONUS_SHOOTING_PADDLE_CONTINUOUS)
	var continuous_shooting_result: Dictionary = continuous_shooting_session.activate_next_bonus()
	_assert(continuous_shooting_result["status"] == "applied", "continuous shooting bonus applies")
	_assert(continuous_shooting_result["effect"] == "shooting_paddle_continuous", "continuous shooting bonus reports effect")
	_assert(bool(continuous_shooting_result["armed"]), "continuous shooting bonus arms the launcher")
	_assert(continuous_shooting_session.is_shooting_paddle_active(), "continuous shooting bonus arms shooting mode")
	_assert(continuous_shooting_session.current_racket_visual_mode() == GameSessionScript.RACKET_VISUAL_MODE_SHOOTING_CONTINUOUS, "continuous shooting bonus switches racket to original launcher insert")
	_assert(continuous_shooting_session.active_projectile_count() == 0, "continuous shooting bonus waits for explicit right-click fire")
	continuous_shooting_session._monster_spawn_cooldown = 999.0
	var continuous_activation_audio_events: Array[String] = continuous_shooting_session.pop_audio_events()
	_assert(not continuous_activation_audio_events.has(GameSessionScript.SFX_EVENT_PROJECTILE_FIRE), "continuous shooting activation does not queue projectile-fire SFX event")
	continuous_shooting_session.update(GameSessionScript.PROJECTILE_FIRE_COOLDOWN_SECONDS)
	_assert(continuous_shooting_session.active_projectile_count() == 0, "continuous shooting does not auto-fire on cooldown")
	var continuous_fire_result: Dictionary = continuous_shooting_session.fire_shooting_paddle()
	_assert(continuous_fire_result["status"] == "fired", "right-click fire shoots continuous projectile")
	_assert(continuous_fire_result["projectile_type"] == GameSessionScript.PROJECTILE_TYPE_CONTINUOUS, "continuous fire uses original continuous projectile")
	_assert(continuous_shooting_session.active_projectile_count() == 1, "continuous right-click fire spawns one projectile")
	var continuous_cooldown_result: Dictionary = continuous_shooting_session.fire_shooting_paddle()
	_assert(continuous_cooldown_result["status"] == "cooldown", "continuous right-click fire respects original cooldown")
	continuous_shooting_session.update(GameSessionScript.PROJECTILE_FIRE_COOLDOWN_SECONDS)
	var continuous_second_fire_result: Dictionary = continuous_shooting_session.fire_shooting_paddle()
	_assert(continuous_second_fire_result["status"] == "fired", "continuous right-click fire works again after cooldown")
	_assert(continuous_shooting_session.active_projectile_count() == 2, "continuous right-click fire creates a second projectile after cooldown")
	_assert(continuous_shooting_session.pop_audio_events().has(GameSessionScript.SFX_EVENT_PROJECTILE_FIRE), "continuous shooting queues projectile-fire SFX event on explicit fire")
	continuous_shooting_session.projectiles.clear()
	for shot_index in range(GameSessionScript.MAX_PROJECTILES):
		continuous_shooting_session.projectiles.append(_projectile(
			GameSessionScript.PROJECTILE_TYPE_CONTINUOUS,
			Vector2(500 - shot_index, 30)
		))
	continuous_shooting_session._projectile_fire_cooldown = 0.0
	continuous_shooting_session.fire_shooting_paddle()
	_assert(continuous_shooting_session.active_projectile_count() == GameSessionScript.MAX_PROJECTILES, "continuous shooting caps active projectiles")

	var projectile_hit_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	var hit_projectiles: Array[Dictionary] = [_projectile(
		GameSessionScript.PROJECTILE_TYPE_CONTINUOUS,
		PlayfieldSpecScript.GRID_ORIGIN + Vector2(2, 2)
	)]
	projectile_hit_session.projectiles = hit_projectiles
	projectile_hit_session.update(0.0)
	_assert(projectile_hit_session.board_state.tile_at(0, 0) == 0, "projectile hit clears brick through board state")
	_assert(projectile_hit_session.consume_board_changed(), "projectile hit marks board for redraw")
	_assert(projectile_hit_session.score == GameSessionScript.NORMAL_BRICK_SCORE, "projectile hit awards normal brick score")
	_assert(projectile_hit_session.active_projectile_count() == 0, "continuous projectile deactivates after brick hit")
	var projectile_hit_audio_events: Array[String] = projectile_hit_session.pop_audio_events()
	_assert(projectile_hit_audio_events.has(GameSessionScript.SFX_EVENT_PROJECTILE_HIT), "projectile brick hit queues projectile-hit SFX event")
	_assert(projectile_hit_audio_events.has(GameSessionScript.SFX_EVENT_BRICK_CLEAR), "projectile brick hit queues brick-clear SFX event")

	var hard_brick_ball_session = _playing_session_from_level(_make_level_from_rows([[8, 1]]))
	hard_brick_ball_session.force_ball(
		PlayfieldSpecScript.GRID_ORIGIN + Vector2(2, 2),
		Vector2(-80, 0)
	)
	hard_brick_ball_session.update(0.01)
	_assert(hard_brick_ball_session.board_state.tile_at(0, 0) == 8, "normal ball hit leaves hard brick intact")
	_assert(hard_brick_ball_session.score == 0, "normal hard-brick hit awards no score")
	_assert(not hard_brick_ball_session.consume_board_changed(), "normal hard-brick hit does not mark the board dirty")
	var hard_brick_ball_effects: Array = hard_brick_ball_session.visible_impact_effects()
	_assert(hard_brick_ball_effects.size() == 1, "normal hard-brick hit spawns original hard-brick impact VFX")
	if hard_brick_ball_effects.size() == 1:
		_assert(int(hard_brick_ball_effects[0]["kind"]) == GameSessionScript.IMPACT_EFFECT_KIND_HARD_BRICK_IMPACT, "normal hard-brick hit uses the original hard-brick impact column")
		_assert(hard_brick_ball_effects[0]["position"] == PlayfieldSpecScript.brick_rect(0, 0).position, "normal hard-brick impact VFX starts at the brick origin")
	_assert(hard_brick_ball_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_HARD_BRICK_HIT], "normal hard-brick hit queues the original hard-brick impact SFX event")

	var strong_projectile_hard_session = _playing_session_from_level(_make_level_from_rows([[8, 1]]))
	var strong_hard_projectiles: Array[Dictionary] = [_projectile(
		GameSessionScript.PROJECTILE_TYPE_STRONG,
		PlayfieldSpecScript.GRID_ORIGIN + Vector2(2, 2)
	)]
	strong_projectile_hard_session.projectiles = strong_hard_projectiles
	strong_projectile_hard_session.update(0.0)
	_assert(strong_projectile_hard_session.board_state.tile_at(0, 0) == 0, "strong projectile force-breaks hard brick")
	_assert(strong_projectile_hard_session.consume_board_changed(), "strong projectile hard-brick hit marks board for redraw")
	_assert(strong_projectile_hard_session.score == GameSessionScript.HARD_BRICK_FORCE_SCORE, "strong projectile hard-brick hit awards original force-break score")
	var strong_hard_effects: Array = strong_projectile_hard_session.visible_impact_effects()
	_assert(strong_hard_effects.size() == 1, "strong projectile hard-brick hit spawns original force-break VFX")
	if strong_hard_effects.size() == 1:
		_assert(int(strong_hard_effects[0]["kind"]) == GameSessionScript.IMPACT_EFFECT_KIND_HARD_BRICK_FORCE_BREAK, "strong projectile hard-brick hit uses the original force-break VFX column")
		_assert(strong_hard_effects[0]["position"] == PlayfieldSpecScript.brick_rect(0, 0).position, "strong projectile hard-brick VFX starts at the brick origin")

	var strong_projectile_downgrade_session = _playing_session_from_level(_make_level_from_rows([[15, 1]]))
	var strong_downgrade_projectiles: Array[Dictionary] = [_projectile(
		GameSessionScript.PROJECTILE_TYPE_STRONG,
		PlayfieldSpecScript.GRID_ORIGIN + Vector2(2, 2)
	)]
	strong_projectile_downgrade_session.projectiles = strong_downgrade_projectiles
	strong_projectile_downgrade_session.update(0.0)
	_assert(strong_projectile_downgrade_session.board_state.tile_at(0, 0) == 0, "strong projectile clears downgrade brick instead of stepping it down")
	_assert(strong_projectile_downgrade_session.score == GameSessionScript.NORMAL_BRICK_SCORE, "strong projectile downgrade hit awards original downgrade score")
	var strong_downgrade_effects: Array = strong_projectile_downgrade_session.visible_impact_effects()
	_assert(strong_downgrade_effects.size() == 1, "strong projectile downgrade hit spawns original force-break VFX")
	if strong_downgrade_effects.size() == 1:
		_assert(int(strong_downgrade_effects[0]["kind"]) == GameSessionScript.IMPACT_EFFECT_KIND_HARD_BRICK_FORCE_BREAK, "strong projectile downgrade hit reuses the original force-break VFX column")

	var projectile_expire_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	var expiring_projectiles: Array[Dictionary] = [_projectile(
		GameSessionScript.PROJECTILE_TYPE_CONTINUOUS,
		Vector2(GameSessionScript.PROJECTILE_EXPIRE_X + 1.0, 200)
	)]
	projectile_expire_session.projectiles = expiring_projectiles
	projectile_expire_session.update(0.0)
	_assert(projectile_expire_session.active_projectile_count() == 0, "projectile expires at original left bound")
	_assert(projectile_expire_session.visible_impact_effects().is_empty(), "projectile expiry does not invent contact VFX")

	_assert(GameSessionScript.monster_frame_count_for_type(0) == 20, "monster trait catalog preserves 20-frame early atlas entries")
	_assert(GameSessionScript.monster_frame_count_for_type(8) == 10, "monster trait catalog preserves original type 8 frame count")
	_assert(GameSessionScript.monster_frame_count_for_type(10) == 11, "monster trait catalog preserves tracking monster frame count")
	_assert(GameSessionScript.monster_motion_mode_for_type(3) == GameSessionScript.MONSTER_MOTION_PADDLE_FOLLOW, "type 3 monster trait follows the racket")
	_assert(GameSessionScript.monster_motion_mode_for_type(10) == GameSessionScript.MONSTER_MOTION_BALL_TRACK, "type 10 monster trait tracks the ball")
	_assert(GameSessionScript.monster_spawn_pool().size() == GameSessionScript.MONSTER_TYPE_COUNT, "registered-only monster pool exposes the original 11-way type range")
	for registered_type_id in range(GameSessionScript.MONSTER_TYPE_COUNT):
		_assert(GameSessionScript.monster_type_is_original_spawned(registered_type_id), "registered-only monster pool includes type %d" % registered_type_id)
	_assert(GameSessionScript.monster_stuns_racket(9), "type 9 trait keeps original racket-stun contact")
	_assert(GameSessionScript.monster_collision_size_for_type(9) == GameSessionScript.MONSTER_TYPE9_COLLISION_SIZE, "type 9 trait uses its full 32px contact box")

	var monster_spawn_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	_assert(monster_spawn_session.active_monster_spawn_pool().size() == GameSessionScript.MONSTER_TYPE_COUNT, "gameplay session uses the registered-only expanded monster pool")
	monster_spawn_session.set_monster_rng_seed(3)
	monster_spawn_session.force_monster_spawn_ready()
	monster_spawn_session.update(0.0)
	_assert(monster_spawn_session.active_monster_count() == 1, "monster spawn gate creates first original monster slot")
	var spawned_monsters: Array = monster_spawn_session.visible_monsters()
	if spawned_monsters.size() == 1:
		_assert(int(spawned_monsters[0]["type_id"]) == 7, "monster spawn consumes the original 11-way type RNG")
		_assert(monster_spawn_session.monster_rect(spawned_monsters[0]).size == GameSessionScript.MONSTER_COLLISION_SIZE, "monster collision rect uses original 26px box")
	var spawn_effects: Array = monster_spawn_session.visible_impact_effects()
	_assert(spawn_effects.size() == 1, "monster spawn creates original spawn VFX")
	if spawn_effects.size() == 1 and spawned_monsters.size() == 1:
		_assert(int(spawn_effects[0]["kind"]) == GameSessionScript.IMPACT_EFFECT_KIND_MONSTER_SPAWN, "monster spawn VFX uses original effect kind")
		_assert(spawn_effects[0]["position"] == spawned_monsters[0]["position"], "monster spawn VFX starts at monster position")
	_assert(monster_spawn_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_MONSTER_SPAWN], "monster spawn queues semantic SFX event")
	monster_spawn_session.force_monster_spawn_ready()
	monster_spawn_session.update(0.0)
	spawned_monsters = monster_spawn_session.visible_monsters()
	if spawned_monsters.size() >= 2:
		_assert(int(spawned_monsters[1]["type_id"]) == 0, "second monster spawn keeps using the 11-way type RNG")
	monster_spawn_session.force_monster_spawn_ready()
	monster_spawn_session.update(0.0)
	spawned_monsters = monster_spawn_session.visible_monsters()
	if spawned_monsters.size() >= 3:
		_assert(int(spawned_monsters[2]["type_id"]) == 6, "third monster spawn keeps using the 11-way type RNG")
	for spawn_index in range(10):
		monster_spawn_session.force_monster_spawn_ready()
		monster_spawn_session.update(0.0)
	_assert(monster_spawn_session.active_monster_count() == GameSessionScript.MAX_MONSTERS, "monster pool enforces original five-slot cap")

	var monster_motion_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	_assert(monster_motion_session.force_monster(Vector2(200, 200), 3, 0), "test helper can force a monster")
	monster_motion_session.update(GameSessionScript.MONSTER_FRAME_SECONDS)
	var moving_monsters: Array = monster_motion_session.visible_monsters()
	_assert(moving_monsters.size() == 1, "forced monster remains active while within lifetime")
	if moving_monsters.size() == 1:
		var expected_monster_distance := GameSessionScript.MONSTER_DEFAULT_SPEED * GameSessionScript.ORIGINAL_ENEMY_UPDATE_HZ * GameSessionScript.MONSTER_FRAME_SECONDS
		var expected_monster_x := 200.0 + expected_monster_distance
		_assert(is_equal_approx(float(moving_monsters[0]["position"].x), expected_monster_x), "type 3 monster advances at original 3-substep enemy speed")
		_assert(is_equal_approx(float(moving_monsters[0]["position"].y), 200.0 - expected_monster_distance), "type 3 eye follows the paddle vertically while moving horizontally")
		_assert(int(moving_monsters[0]["frame"]) == 1, "monster animation advances at original cadence")
	var monster_split_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	_assert(monster_split_session.force_monster(Vector2(200, 200), 3, 0), "test helper can force split-step monster")
	monster_split_session.update(GameSessionScript.MONSTER_FRAME_SECONDS * 0.5)
	monster_split_session.update(GameSessionScript.MONSTER_FRAME_SECONDS * 0.5)
	var split_monsters: Array = monster_split_session.visible_monsters()
	if moving_monsters.size() == 1 and split_monsters.size() == 1:
		_assert(is_equal_approx(float(split_monsters[0]["position"].x), float(moving_monsters[0]["position"].x)), "monster movement is stable across split deltas")
		_assert(is_equal_approx(float(split_monsters[0]["position"].y), float(moving_monsters[0]["position"].y)), "monster y movement is stable across split deltas")
	var eye_follow_session = _game_session_from_level(_make_level_from_rows([[1]]))
	eye_follow_session.set_monster_rng_seed(1)
	eye_follow_session.move_racket_to(120.0)
	eye_follow_session.force_ball(Vector2(300, 430), Vector2.ZERO)
	_assert(eye_follow_session.force_monster(Vector2(220, 260), 3, 0), "test helper can force a paddle-following eye")
	eye_follow_session.update(1.0 / GameSessionScript.ORIGINAL_ENEMY_UPDATE_HZ)
	var eye_monsters: Array = eye_follow_session.visible_monsters()
	if eye_monsters.size() == 1:
		_assert(float(eye_monsters[0]["position"].y) < 260.0, "type 3 eye follows the paddle instead of the active ball")
	monster_motion_session.monsters[0]["age"] = GameSessionScript.MONSTER_LIFETIME_SECONDS - 0.01
	monster_motion_session.update(0.02)
	_assert(monster_motion_session.active_monster_count() == 0, "monster expires after original lifetime")
	var timeout_effects: Array = monster_motion_session.visible_impact_effects()
	_assert(timeout_effects.size() == 1, "monster timeout creates original timeout VFX")
	if timeout_effects.size() == 1:
		_assert(int(timeout_effects[0]["kind"]) == GameSessionScript.IMPACT_EFFECT_KIND_MONSTER_TIMEOUT, "monster timeout VFX uses original effect kind")
	_assert(monster_motion_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_MONSTER_EXPIRE], "monster timeout queues original expire SFX event")

	var monster_boundary_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	monster_boundary_session.force_monster(
		Vector2(PlayfieldSpecScript.WALL_INNER_LEFT_X - 4.0, 200),
		6,
		180
	)
	monster_boundary_session.update(0.0)
	var bounded_monsters: Array = monster_boundary_session.visible_monsters()
	_assert(bounded_monsters.size() == 1, "monster remains active after hitting the playfield boundary")
	if bounded_monsters.size() == 1:
		_assert(bounded_monsters[0]["position"].x == PlayfieldSpecScript.WALL_INNER_LEFT_X, "monster boundary clamps the original 32px visual to the inner wall")
		_assert(monster_boundary_session.monster_rect(bounded_monsters[0]).position.x == PlayfieldSpecScript.WALL_INNER_LEFT_X + GameSessionScript.MONSTER_COLLISION_OFFSET.x, "normal monster contact box remains inset after wall clamp")
		_assert(int(bounded_monsters[0]["angle"]) == 0, "monster boundary collision reflects horizontal motion")
	var tracking_boundary_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	tracking_boundary_session.force_monster(
		Vector2(PlayfieldSpecScript.WALL_INNER_LEFT_X - 4.0, 200),
		10,
		180
	)
	tracking_boundary_session.update(0.0)
	var tracking_boundary_monsters: Array = tracking_boundary_session.visible_monsters()
	if tracking_boundary_monsters.size() == 1:
		_assert(tracking_boundary_monsters[0]["position"].x == PlayfieldSpecScript.WALL_INNER_LEFT_X, "tracking monster clamps to original inner wall")
		_assert(int(tracking_boundary_monsters[0]["angle"]) == 180, "tracking monster wall clamp does not reflect its tracking angle")
	var eye_boundary_follow_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	eye_boundary_follow_session.move_racket_to(430.0)
	eye_boundary_follow_session.force_monster(Vector2(220, PlayfieldSpecScript.WALL_INNER_TOP_Y - 4.0), 3, 90)
	eye_boundary_follow_session.update(0.0)
	eye_boundary_follow_session.update(1.0 / GameSessionScript.ORIGINAL_ENEMY_UPDATE_HZ)
	var boundary_eye_monsters: Array = eye_boundary_follow_session.visible_monsters()
	if boundary_eye_monsters.size() == 1:
		_assert(float(boundary_eye_monsters[0]["position"].y) > PlayfieldSpecScript.WALL_INNER_TOP_Y, "type 3 keeps following the paddle after a wall clamp")

	var tracking_nearest_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	var tracking_nearest_balls: Array[Dictionary] = [
		_active_ball(Vector2(191, 70)),
		_active_ball(Vector2(291, 207)),
	]
	tracking_nearest_session.balls = tracking_nearest_balls
	tracking_nearest_session.force_monster(Vector2(200, 200), 10, 0)
	tracking_nearest_session.update(1.0 / GameSessionScript.ORIGINAL_ENEMY_UPDATE_HZ)
	var tracking_nearest_monsters: Array = tracking_nearest_session.visible_monsters()
	if tracking_nearest_monsters.size() == 1:
		_assert(is_equal_approx(float(tracking_nearest_monsters[0]["angle"]), 0.0), "type 10 tracks the nearest active ball instead of the first active slot")

	var tracking_non_stricked_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	var tracking_non_stricked_balls: Array[Dictionary] = [
		_active_ball(Vector2(207, 70), Vector2.ZERO, GameSessionScript.BALL_SIZE, GameSessionScript.BALL_TYPE_NON_STRICKED),
		_active_ball(Vector2(291, 207)),
	]
	tracking_non_stricked_session.balls = tracking_non_stricked_balls
	tracking_non_stricked_session.force_monster(Vector2(200, 200), 10, 0)
	tracking_non_stricked_session.update(1.0 / GameSessionScript.ORIGINAL_ENEMY_UPDATE_HZ)
	var tracking_non_stricked_monsters: Array = tracking_non_stricked_session.visible_monsters()
	if tracking_non_stricked_monsters.size() == 1:
		_assert(is_equal_approx(float(tracking_non_stricked_monsters[0]["angle"]), 0.0), "type 10 ignores original non-stricked ball type when tracking")

	var monster_ball_hit_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	monster_ball_hit_session.set_collision_rng_seed(1)
	monster_ball_hit_session.force_ball(Vector2(200, 200), Vector2.ZERO)
	monster_ball_hit_session.force_monster(Vector2(200, 200), 3, 0)
	monster_ball_hit_session.update(0.0)
	_assert(monster_ball_hit_session.active_monster_count() == 0, "ball collision removes active monster")
	_assert(monster_ball_hit_session.score == GameSessionScript.MONSTER_BALL_HIT_SCORE, "ball collision awards original ball-contact monster score")
	var monster_ball_score_popups: Array[Dictionary] = monster_ball_hit_session.visible_score_popups()
	_assert(monster_ball_score_popups.size() == 1, "ball monster collision spawns original floating score VFX")
	if monster_ball_score_popups.size() == 1:
		_assert(int(monster_ball_score_popups[0]["value"]) == GameSessionScript.MONSTER_BALL_HIT_SCORE, "monster score popup uses original ball-contact value")
		_assert(monster_ball_score_popups[0]["position"] == Vector2(200, 200), "monster score popup starts at enemy position")
	_assert(not monster_ball_hit_session.first_ball_velocity().is_zero_approx(), "ball collision changes the ball trajectory")
	_assert(monster_ball_hit_session.visible_impact_effects().size() == 1, "ball collision spawns monster hit VFX")
	_assert(monster_ball_hit_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_MONSTER_HIT], "monster collision queues monster-hit SFX event")
	monster_ball_hit_session.update(GameSessionScript.IMPACT_EFFECT_DURATION_SECONDS)
	_assert(monster_ball_hit_session.visible_impact_effects().is_empty(), "monster hit VFX expires through the session effect pool")

	var monster_ball_radius_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	monster_ball_radius_session.force_ball(Vector2(200, 200), Vector2.ZERO)
	monster_ball_radius_session.force_monster(Vector2(224, 200), 3, 0)
	monster_ball_radius_session.update(0.0)
	_assert(monster_ball_radius_session.active_monster_count() == 0, "ball monster collision uses original radius test instead of rectangle overlap")
	var monster_ball_radius_miss_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	monster_ball_radius_miss_session.force_ball(Vector2(200, 200), Vector2.ZERO)
	monster_ball_radius_miss_session.force_monster(Vector2(225, 200), 3, 0)
	monster_ball_radius_miss_session.update(0.0)
	_assert(monster_ball_radius_miss_session.active_monster_count() == 1, "ball monster collision keeps the original strict radius threshold")

	var monster_speed_session = _game_session_from_level(_make_level_from_rows([[1]]))
	monster_speed_session.launch_ready_ball()
	var expected_enemy_hit_speed: float = monster_speed_session.first_ball_velocity().length()
	var slowed_ball: Dictionary = monster_speed_session.balls[0]
	slowed_ball["position"] = Vector2(220, 200)
	slowed_ball["velocity"] = Vector2(-40, 0)
	monster_speed_session.balls[0] = slowed_ball
	monster_speed_session.force_monster(Vector2(220, 200), 3, 0)
	monster_speed_session.update(0.0)
	_assert(is_equal_approx(monster_speed_session.first_ball_velocity().length(), expected_enemy_hit_speed), "enemy collision restores the active ball speed instead of preserving a slowed vector")

	var type1_ball_hit_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	type1_ball_hit_session.set_collision_rng_seed(1)
	type1_ball_hit_session.force_ball(Vector2(200, 200), Vector2.ZERO)
	type1_ball_hit_session.force_monster(Vector2(200, 200), 1, 0)
	type1_ball_hit_session.update(0.0)
	_assert(type1_ball_hit_session.active_monster_count() == 1, "type 1 monster survives original ball contact")
	_assert(type1_ball_hit_session.score == GameSessionScript.MONSTER_BALL_HIT_SCORE, "type 1 monster ball contact still awards original score")
	_assert(type1_ball_hit_session.visible_score_popups().size() == 1, "surviving type 1 monster contact still spawns score-popup VFX")
	_assert(not type1_ball_hit_session.first_ball_velocity().is_zero_approx(), "type 1 monster ball contact still rotates the ball")
	var type1_ball_angle := fposmod(rad_to_deg(atan2(-type1_ball_hit_session.first_ball_velocity().y, type1_ball_hit_session.first_ball_velocity().x)), 360.0)
	_assert(is_equal_approx(type1_ball_angle, float(GameSessionScript.MONSTER_TYPE1_BALL_ROTATION_DEGREES)), "type 1 monster applies the original fixed ball turn")

	var fireball_enemy_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	var fireball_enemy_velocity := Vector2(100, 0)
	fireball_enemy_session.force_ball(Vector2(200, 200), fireball_enemy_velocity, GameSessionScript.BALL_SIZE, GameSessionScript.BALL_TYPE_FIREBALL)
	fireball_enemy_session.force_monster(Vector2(200, 200), 3, 0)
	fireball_enemy_session.update(0.0)
	_assert(fireball_enemy_session.active_monster_count() == 0, "fireballs still remove normal monsters")
	_assert(fireball_enemy_session.first_ball_velocity() == fireball_enemy_velocity, "fireball monster contact does not rotate the ball in the original")

	var non_stricked_enemy_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	non_stricked_enemy_session.force_ball(Vector2(200, 200), Vector2.ZERO, GameSessionScript.BALL_SIZE, GameSessionScript.BALL_TYPE_NON_STRICKED)
	non_stricked_enemy_session.force_monster(Vector2(200, 200), 3, 0)
	non_stricked_enemy_session.update(0.0)
	_assert(non_stricked_enemy_session.active_monster_count() == 1, "non-stricked balls pass through monsters like the original type 2 ball")
	_assert(non_stricked_enemy_session.score == 0, "non-stricked monster pass-through awards no score")
	_assert(non_stricked_enemy_session.first_ball_velocity().is_zero_approx(), "non-stricked monster pass-through leaves ball trajectory unchanged")

	var monster_racket_hit_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	monster_racket_hit_session.move_racket_to(220.0)
	var monster_racket_position := Vector2(
		GameSessionScript.RACKET_X - GameSessionScript.MONSTER_COLLISION_OFFSET.x - 8.0,
		monster_racket_hit_session.racket_rect().position.y + 18.0
	)
	monster_racket_hit_session.force_monster(monster_racket_position, 3, 0)
	monster_racket_hit_session.update(0.0)
	_assert(monster_racket_hit_session.active_monster_count() == 0, "racket collision removes active monster")
	_assert(monster_racket_hit_session.score == GameSessionScript.MONSTER_SCORE, "racket collision uses original paddle/projectile monster score")
	_assert(monster_racket_hit_session.visible_impact_effects().size() == 1, "racket collision spawns monster hit VFX")
	_assert(monster_racket_hit_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_MONSTER_HIT], "racket monster collision queues monster-hit SFX event")

	var monster_stun_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	monster_stun_session.force_ball(Vector2(300, 200), Vector2.ZERO)
	monster_stun_session.move_racket_to(220.0)
	var stunned_start_y: float = monster_stun_session.racket_rect().position.y
	monster_stun_session.force_monster(
		Vector2(GameSessionScript.RACKET_X - GameSessionScript.MONSTER_COLLISION_OFFSET.x - 8.0, stunned_start_y + 18.0),
		9,
		0
	)
	monster_stun_session.update(0.0)
	_assert(monster_stun_session.is_racket_stunned(), "type 9 enemy contact stuns the racket")
	_assert(monster_stun_session.score == GameSessionScript.MONSTER_TYPE9_STUN_SCORE, "type 9 stun contact awards original 30-point score")
	monster_stun_session.move_racket_to(10000.0)
	_assert(monster_stun_session.racket_rect().position.y == stunned_start_y, "stunned racket ignores player movement")
	monster_stun_session.update(GameSessionScript.RACKET_STUN_DURATION_SECONDS)
	_assert(not monster_stun_session.is_racket_stunned(), "racket stun expires after original duration")
	monster_stun_session.move_racket_to(10000.0)
	_assert(monster_stun_session.racket_rect().end.y == GameSessionScript.RACKET_MAX_BOTTOM, "racket movement resumes after stun")

	var bee_spawn_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	bee_spawn_session.move_racket_to(220.0)
	bee_spawn_session.force_bee_spawn_ready()
	bee_spawn_session.update(0.0)
	_assert(bee_spawn_session.active_bee_count() == 1, "bee spawn gate creates a floating hazard")
	var spawned_bees: Array = bee_spawn_session.visible_bees()
	if spawned_bees.size() == 1:
		_assert(spawned_bees[0]["position"] == Vector2(GameSessionScript.BEE_SPAWN_X, bee_spawn_session.racket_rect().position.y + 13.0), "bee starts from original racket-relative y position")
		_assert(bee_spawn_session.bee_rect(spawned_bees[0]).size == GameSessionScript.BEE_COLLISION_SIZE, "bee collision uses original 36px contact box")
	var bee_spawn_audio_payloads: Array[Dictionary] = bee_spawn_session.pop_audio_event_payloads()
	_assert(_payload_events(bee_spawn_audio_payloads) == [GameSessionScript.SFX_EVENT_BEE_SPAWN], "bee spawn queues EffBee SFX event")
	if bee_spawn_audio_payloads.size() == 1:
		_assert(is_equal_approx(float(bee_spawn_audio_payloads[0].get("pan100", 0.0)), GameSessionScript.SFX_BEE_SPAWN_PAN100), "bee spawn SFX payload preserves the original fixed left pan")
	bee_spawn_session.update(GameSessionScript.BEE_FRAME_SECONDS)
	spawned_bees = bee_spawn_session.visible_bees()
	var expected_bee_x := GameSessionScript.BEE_SPAWN_X + GameSessionScript.BEE_STEP_X * GameSessionScript.ORIGINAL_ENEMY_UPDATE_HZ * GameSessionScript.BEE_FRAME_SECONDS
	if spawned_bees.size() == 1:
		_assert(is_equal_approx(float(spawned_bees[0]["position"].x), expected_bee_x), "bee advances at original 3-substep enemy speed")
		_assert(int(spawned_bees[0]["frame"]) == 1, "bee animation advances through original 5ms frames")
	var bee_split_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	bee_split_session.force_bee(Vector2(GameSessionScript.BEE_SPAWN_X, 100))
	bee_split_session.update(GameSessionScript.BEE_FRAME_SECONDS * 0.5)
	bee_split_session.update(GameSessionScript.BEE_FRAME_SECONDS * 0.5)
	var split_bees: Array = bee_split_session.visible_bees()
	if spawned_bees.size() == 1 and split_bees.size() == 1:
		_assert(is_equal_approx(float(split_bees[0]["position"].x), expected_bee_x), "bee movement is stable across split deltas")

	var bee_ball_hit_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	bee_ball_hit_session.force_ball(Vector2(200, 200), Vector2.ZERO)
	bee_ball_hit_session.force_bee(Vector2(200, 200))
	bee_ball_hit_session.update(0.0)
	_assert(bee_ball_hit_session.active_bee_count() == 0, "ball collision removes active bee")
	_assert(bee_ball_hit_session.score == GameSessionScript.BEE_BALL_HIT_SCORE, "ball collision awards bee ball-contact score")
	var bee_ball_score_popups: Array[Dictionary] = bee_ball_hit_session.visible_score_popups()
	_assert(bee_ball_score_popups.size() == 1, "bee ball collision spawns original floating score VFX")
	if bee_ball_score_popups.size() == 1:
		_assert(int(bee_ball_score_popups[0]["value"]) == GameSessionScript.BEE_BALL_HIT_SCORE, "bee score popup uses original ball-contact value")
		_assert(bee_ball_score_popups[0]["position"] == Vector2(200, 200), "bee score popup starts at enemy position")
	_assert(not bee_ball_hit_session.first_ball_velocity().is_zero_approx(), "bee ball collision changes the ball trajectory")
	_assert(not bee_ball_hit_session.is_racket_stunned(), "bee ball collision does not stun the racket")
	_assert(bee_ball_hit_session.visible_impact_effects().size() == 1, "bee ball collision spawns impact VFX")
	_assert(
		bee_ball_hit_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_BEE_STOP, GameSessionScript.SFX_EVENT_MONSTER_HIT],
		"bee ball collision stops EffBee before monster-hit SFX"
	)
	var bee_ball_radius_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	bee_ball_radius_session.force_ball(Vector2(200, 200), Vector2.ZERO)
	bee_ball_radius_session.force_bee(Vector2(232, 200))
	bee_ball_radius_session.update(0.0)
	_assert(bee_ball_radius_session.active_bee_count() == 0, "ball bee collision uses original radius test instead of rectangle overlap")
	var bee_ball_radius_miss_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	bee_ball_radius_miss_session.force_ball(Vector2(200, 200), Vector2.ZERO)
	bee_ball_radius_miss_session.force_bee(Vector2(233, 200))
	bee_ball_radius_miss_session.update(0.0)
	_assert(bee_ball_radius_miss_session.active_bee_count() == 1, "ball bee collision keeps the original strict radius threshold")
	var fireball_bee_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	var fireball_bee_velocity := Vector2(100, 0)
	fireball_bee_session.force_ball(Vector2(200, 200), fireball_bee_velocity, GameSessionScript.BALL_SIZE, GameSessionScript.BALL_TYPE_FIREBALL)
	fireball_bee_session.force_bee(Vector2(200, 200))
	fireball_bee_session.update(0.0)
	_assert(fireball_bee_session.active_bee_count() == 0, "fireballs still remove the bee hazard")
	_assert(fireball_bee_session.first_ball_velocity() == fireball_bee_velocity, "fireball bee contact does not rotate the ball in the original")
	var non_stricked_bee_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	non_stricked_bee_session.force_ball(Vector2(200, 200), Vector2.ZERO, GameSessionScript.BALL_SIZE, GameSessionScript.BALL_TYPE_NON_STRICKED)
	non_stricked_bee_session.force_bee(Vector2(200, 200))
	non_stricked_bee_session.update(0.0)
	_assert(non_stricked_bee_session.active_bee_count() == 1, "non-stricked balls pass through the bee hazard")
	_assert(non_stricked_bee_session.score == 0, "non-stricked bee pass-through awards no score")

	var bee_racket_hit_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	bee_racket_hit_session.force_ball(Vector2(300, 200), Vector2.ZERO)
	bee_racket_hit_session.move_racket_to(220.0)
	var bee_hit_position := Vector2(
		GameSessionScript.RACKET_X - GameSessionScript.BEE_COLLISION_OFFSET.x - 8.0,
		bee_racket_hit_session.racket_rect().position.y + 18.0
	)
	bee_racket_hit_session.force_bee(bee_hit_position)
	bee_racket_hit_session.update(0.0)
	_assert(bee_racket_hit_session.active_bee_count() == 0, "racket collision removes active bee")
	_assert(bee_racket_hit_session.score == GameSessionScript.BEE_STUN_SCORE, "bee hit awards original stun-hazard score")
	_assert(bee_racket_hit_session.is_racket_stunned(), "bee hit stuns the racket")
	var bee_stun_indicators: Array = bee_racket_hit_session.active_bonus_indicators()
	var bee_stun_indicator := _indicator_for_icon(bee_stun_indicators, GameSessionScript.RACKET_STUN_STATUS_ICON_INDEX)
	_assert(not bee_stun_indicator.is_empty(), "bee stun exposes original stuck-racket status indicator")
	if not bee_stun_indicator.is_empty():
		_assert(int(bee_stun_indicator["value"]) == int(GameSessionScript.RACKET_STUN_DURATION_SECONDS), "bee stun status starts at original duration")
	_assert(bee_racket_hit_session.visible_impact_effects().size() == 1, "bee hit spawns impact VFX")
	_assert(
		bee_racket_hit_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_BEE_STOP, GameSessionScript.SFX_EVENT_MONSTER_HIT],
		"bee hit stops EffBee before monster-hit SFX"
	)
	bee_racket_hit_session.update(1.0)
	var bee_stun_countdown: Array = bee_racket_hit_session.active_bonus_indicators()
	bee_stun_indicator = _indicator_for_icon(bee_stun_countdown, GameSessionScript.RACKET_STUN_STATUS_ICON_INDEX)
	_assert(not bee_stun_indicator.is_empty(), "bee stun status remains visible while stun is active")
	if not bee_stun_indicator.is_empty():
		_assert(int(bee_stun_indicator["value"]) == int(GameSessionScript.RACKET_STUN_DURATION_SECONDS) - 1, "bee stun status counts down once per second")
	bee_racket_hit_session.update(GameSessionScript.RACKET_STUN_DURATION_SECONDS - 1.0)
	_assert(_indicator_for_icon(bee_racket_hit_session.active_bonus_indicators(), GameSessionScript.RACKET_STUN_STATUS_ICON_INDEX).is_empty(), "expired bee stun clears stuck-racket status indicator")

	var snake_vfx_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	var snake_inputs: Array[Dictionary] = [
		{"position": Vector2(10, 20), "kind": 0},
		{"position": Vector2(30, 40), "kind": 19},
		{"position": Vector2(50, 60), "kind": 25},
		{"position": Vector2(70, 80), "kind": -5, "active": false},
	]
	_assert(snake_vfx_session.force_snake_vfx_segments_for_test(snake_inputs) == 4, "Snake VFX test seam stores source slots without activating gameplay")
	var snake_segments: Array = snake_vfx_session.visible_snake_segments()
	_assert(snake_segments.size() == 3, "Snake VFX visibility filters inactive original slots")
	if snake_segments.size() == 3:
		_assert(snake_segments[0]["position"] == Vector2(10, 20), "Snake VFX preserves segment position")
		_assert(int(snake_segments[0]["kind"]) == 0, "Snake VFX preserves first original kind")
		_assert(int(snake_segments[1]["kind"]) == 19, "Snake VFX preserves final original kind")
		_assert(int(snake_segments[2]["kind"]) == GameSessionScript.SNAKE_KIND_COUNT - 1, "Snake VFX clamps out-of-range kinds to the original atlas range")
	var capped_snake_inputs: Array[Dictionary] = []
	for snake_index in range(GameSessionScript.MAX_SNAKE_SEGMENTS + 5):
		capped_snake_inputs.append({"position": Vector2(snake_index, snake_index), "kind": snake_index})
	_assert(
		snake_vfx_session.force_snake_vfx_segments_for_test(capped_snake_inputs) == GameSessionScript.MAX_SNAKE_SEGMENTS,
		"Snake VFX test seam enforces the original 100-slot cap"
	)
	_assert(snake_vfx_session.active_snake_segment_count() == GameSessionScript.MAX_SNAKE_SEGMENTS, "Snake VFX active count reflects visible capped slots")
	snake_vfx_session.reset_round()
	_assert(snake_vfx_session.visible_snake_segments().is_empty(), "round reset clears dormant Snake VFX segments")
	_assert(
		snake_vfx_session.snake_rect({"position": Vector2(33, 44)}) == Rect2(Vector2(33, 44), GameSessionScript.SNAKE_SEGMENT_SIZE),
		"Snake VFX collision rect uses the original 10x10 segment footprint"
	)
	_assert(not GameSessionScript.SNAKE_RUNTIME_ACTIVATION_PROVEN, "Snake VFX gameplay activation stays disabled until an original production spawn write is proven")
	var snake_activation_evidence: Dictionary = GameSessionScript.snake_runtime_activation_evidence()
	_assert(not bool(snake_activation_evidence.get("proven", true)), "Snake VFX evidence keeps production activation unproven")
	_assert(String(snake_activation_evidence.get("policy", "")) == GameSessionScript.SNAKE_ACTIVATION_POLICY, "Snake VFX evidence records the active implementation policy")
	_assert(String(snake_activation_evidence.get("activation_flag_offset", "")) == "0x0A74", "Snake VFX evidence records the original active-slot offset")
	_assert(int(snake_activation_evidence.get("slot_count", 0)) == GameSessionScript.MAX_SNAKE_SEGMENTS, "Snake VFX evidence records the original 100-slot pool")
	_assert(String(snake_activation_evidence.get("reset", "")).find("sub_419600") != -1, "Snake VFX evidence names the original reset helper")
	_assert(String(snake_activation_evidence.get("reset", "")).find("0x190") != -1, "Snake VFX evidence records the original cleared dword count")
	_assert(String(snake_activation_evidence.get("runtime_loop", "")).find("sub_40DAF0") != -1, "Snake VFX evidence records the original runtime-loop caller")
	_assert(String(snake_activation_evidence.get("update", "")).find("+0x0A74") != -1, "Snake VFX evidence records that update requires a pre-active slot")
	_assert(String(snake_activation_evidence.get("update", "")).find("50 ms") != -1, "Snake VFX evidence records the original Snake movement gate")
	_assert(String(snake_activation_evidence.get("update_guard", "")).find("+0x0A74 == 1") != -1, "Snake VFX evidence records the original update guard")
	_assert(String(snake_activation_evidence.get("collision", "")).find("sub_41B390") != -1, "Snake VFX evidence names the original ball/projectile truncation helper")
	var snake_level_start_candidate := String(snake_activation_evidence.get("level_start_candidate", ""))
	_assert(snake_level_start_candidate.find("sub_40E580") != -1, "Snake VFX evidence records the level-start initializer candidate")
	_assert(snake_level_start_candidate.find("sub_41A780") != -1, "Snake VFX evidence names the original initializer candidate")
	_assert(snake_level_start_candidate.find("stubbed out") != -1, "Snake VFX evidence records that the initializer candidate is stubbed out")
	var snake_pointer_scan := String(snake_activation_evidence.get("pointer_write_scan", ""))
	_assert(snake_pointer_scan.find("+0x0A70..+0x10B4") != -1, "Snake VFX evidence records the expanded pointer-write audit range")
	_assert(snake_pointer_scan.find("unrelated ball/projectile/menu") != -1, "Snake VFX evidence documents raw displacement false-positive contexts")
	_assert(snake_pointer_scan.find("No filtered path writes +0x0A74 := 1") != -1, "Snake VFX evidence records the filtered no-writer result")
	_assert(String(snake_activation_evidence.get("write_scan", "")).find(GameSessionScript.SNAKE_DIRECT_WRITE_AUDIT_RANGE) != -1, "Snake VFX evidence records the audited direct-write range")
	_assert(String(snake_activation_evidence.get("write_scan", "")).find("no production writer") != -1, "Snake VFX evidence records the missing activation writer")
	_assert(String(snake_activation_evidence.get("input_state_overlap", "")).find("sub_415A70") != -1, "Snake VFX evidence excludes the DirectInput offset overlap")
	_assert(String(snake_activation_evidence.get("level_tail_audit_range", "")) == GameSessionScript.SNAKE_LEVEL_TAIL_AUDIT_RANGE, "Snake VFX evidence records the audited level-tail range")
	var snake_tail_audit := String(snake_activation_evidence.get("level_tail_audit", ""))
	_assert(snake_tail_audit.find("Flystone #25") != -1, "Snake VFX evidence records the suspicious Flystone tail byte")
	_assert(snake_tail_audit.find("170 padding") != -1, "Snake VFX evidence records the repeated padding tail bytes")
	_assert(snake_tail_audit.find("sub_40FF40") != -1, "Snake VFX evidence names the original level-tail loader")
	_assert(snake_tail_audit.find("sub_410CC0") != -1, "Snake VFX evidence names the audited bonus-stock consumer")
	_assert(snake_tail_audit.find("indices 0..21") != -1, "Snake VFX evidence records that only the first 22 tail bytes feed bonus stock")
	var snake_bonus_audit := String(snake_activation_evidence.get("bonus_activation_audit", ""))
	_assert(snake_bonus_audit.find("sub_4110E0") != -1, "Snake VFX evidence names the original bonus dispatcher")
	_assert(snake_bonus_audit.find("no case writes Snake +0x0A74") != -1, "Snake VFX evidence records that bonus dispatch does not activate Snake")
	_assert(String(snake_activation_evidence.get("activation", "")).find("No production write") != -1, "Snake VFX evidence records the missing production initializer")
	_assert(String(snake_activation_evidence.get("activation", "")).find("normal gameplay spawning stays disabled") != -1, "Snake VFX evidence records the evidence-gated gameplay policy")
	_assert(String(GameSessionScript.SNAKE_IDA_EVIDENCE).find("+0x0A74") != -1, "Snake VFX text evidence records the original active-slot offset")
	_assert(String(GameSessionScript.SNAKE_IDA_EVIDENCE).find(GameSessionScript.SNAKE_DIRECT_WRITE_AUDIT_RANGE) != -1, "Snake VFX text evidence records the direct-write audit range")
	_assert(String(GameSessionScript.SNAKE_IDA_EVIDENCE).find("sub_40DAF0") != -1, "Snake VFX text evidence records the gameplay-loop caller")
	_assert(String(GameSessionScript.SNAKE_IDA_EVIDENCE).find("sub_41A780") != -1, "Snake VFX text evidence records the stubbed initializer candidate")
	_assert(String(GameSessionScript.SNAKE_IDA_EVIDENCE).find("level_tail_bytes[22:50]") != -1, "Snake VFX text evidence records the level-tail audit")
	var snake_dormant_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	snake_dormant_session._monster_spawn_cooldown = 999.0
	snake_dormant_session._bee_spawn_delay_remaining = 999.0
	snake_dormant_session.update(GameSessionScript.SNAKE_UPDATE_SECONDS * 4.0)
	_assert(snake_dormant_session.visible_snake_segments().is_empty(), "normal gameplay update keeps Snake VFX dormant without proven original activation evidence")
	var snake_tail_flag: Array[int] = []
	for tail_index in range(LevelDataScript.LEVEL_TAIL_SIZE):
		snake_tail_flag.append(0)
	snake_tail_flag[29] = 1
	var snake_tail_flag_session = _playing_session_from_level(_make_level_from_rows([[1]], snake_tail_flag))
	snake_tail_flag_session._monster_spawn_cooldown = 999.0
	snake_tail_flag_session._bee_spawn_delay_remaining = 999.0
	snake_tail_flag_session.update(GameSessionScript.SNAKE_UPDATE_SECONDS * 4.0)
	_assert(snake_tail_flag_session.visible_snake_segments().is_empty(), "Flystone-style tail byte 29 anomaly does not activate Snake without original write evidence")
	var snake_tail_padding: Array[int] = []
	for tail_index in range(LevelDataScript.LEVEL_TAIL_SIZE):
		snake_tail_padding.append(0)
	for tail_index in range(30, LevelDataScript.LEVEL_TAIL_SIZE):
		snake_tail_padding[tail_index] = 170
	var snake_tail_padding_session = _playing_session_from_level(_make_level_from_rows([[1]], snake_tail_padding))
	snake_tail_padding_session._monster_spawn_cooldown = 999.0
	snake_tail_padding_session._bee_spawn_delay_remaining = 999.0
	snake_tail_padding_session.update(GameSessionScript.SNAKE_UPDATE_SECONDS * 4.0)
	_assert(snake_tail_padding_session.visible_snake_segments().is_empty(), "170-padded level tails do not activate Snake without original write evidence")

	var snake_preview_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	var snake_preview_result: Dictionary = snake_preview_session.debug_spawn_snake_vfx_preview()
	_assert(snake_preview_result["status"] == "spawned", "debug Snake VFX preview reports a spawned state")
	_assert(int(snake_preview_result["count"]) == 8, "debug Snake VFX preview creates a bounded source-backed segment chain")
	_assert(str(snake_preview_result.get("source", "")) == "debug_only", "debug Snake VFX preview is marked as a non-production activation")
	_assert(not bool(snake_preview_result.get("runtime_activation_proven", true)), "debug Snake VFX preview reports unresolved production activation evidence")
	var preview_evidence: Dictionary = snake_preview_result.get("evidence", {})
	_assert(String(preview_evidence.get("activation_flag_offset", "")) == "0x0A74", "debug Snake VFX preview carries the same runtime activation evidence")
	var snake_preview_segments: Array = snake_preview_session.visible_snake_segments()
	if snake_preview_segments.size() == 8:
		_assert(int(snake_preview_segments[0]["kind"]) == GameSessionScript.SNAKE_KIND_LEFT, "debug Snake VFX preview starts with left-moving body segments")
		_assert(int(snake_preview_segments[7]["kind"]) == GameSessionScript.SNAKE_TERMINAL_LEFT, "debug Snake VFX preview ends with the left terminal segment")
	var snake_clear_result: Dictionary = snake_preview_session.debug_clear_snake_vfx_preview()
	_assert(snake_clear_result["status"] == "cleared", "debug Snake VFX clear reports a cleared state")
	_assert(int(snake_clear_result["count"]) == 8, "debug Snake VFX clear reports the removed visible segment count")
	_assert(snake_preview_session.visible_snake_segments().is_empty(), "debug Snake VFX clear removes preview segments")

	var snake_move_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	snake_move_session.force_snake_vfx_segments_for_test([
		{"position": Vector2(100, 100), "kind": GameSessionScript.SNAKE_KIND_LEFT},
		{"position": Vector2(120, 100), "kind": GameSessionScript.SNAKE_KIND_UP},
		{"position": Vector2(140, 100), "kind": GameSessionScript.SNAKE_TERMINAL_RIGHT},
	])
	snake_move_session.update(GameSessionScript.SNAKE_UPDATE_SECONDS)
	var snake_gate_segments: Array = snake_move_session.visible_snake_segments()
	if snake_gate_segments.size() == 3:
		_assert(snake_gate_segments[0]["position"] == Vector2(100, 100), "Snake VFX movement waits for the original strict 50ms gate")
	snake_move_session.update(0.001)
	var snake_moved_segments: Array = snake_move_session.visible_snake_segments()
	if snake_moved_segments.size() == 3:
		_assert(snake_moved_segments[0]["position"] == Vector2(90, 100), "left Snake VFX body segments step by the original 10 pixels")
		_assert(snake_moved_segments[1]["position"] == Vector2(120, 90), "up Snake VFX body segments step by the original 10 pixels")
		_assert(snake_moved_segments[2]["position"] == Vector2(150, 100), "terminal Snake VFX segments keep their encoded movement direction")
	_assert(snake_move_session.pop_audio_events().is_empty(), "Snake VFX movement stays silent until an original SFX route is proven")

	var snake_ball_hit_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	snake_ball_hit_session.force_snake_vfx_segments_for_test([
		{"position": Vector2(198, 200), "kind": 4},
		{"position": Vector2(210, 200), "kind": 5},
		{"position": Vector2(220, 200), "kind": 6},
		{"position": Vector2(232, 200), "kind": 7},
	])
	snake_ball_hit_session.force_ball(Vector2(220, 200), Vector2.ZERO, GameSessionScript.SNAKE_SEGMENT_SIZE.x)
	snake_ball_hit_session.update(0.0)
	var snake_after_ball_hit: Array = snake_ball_hit_session.visible_snake_segments()
	_assert(snake_after_ball_hit.size() == 2, "ball overlap truncates the Snake VFX chain at the hit segment")
	if snake_after_ball_hit.size() == 2:
		_assert(int(snake_after_ball_hit[1]["kind"]) == GameSessionScript.SNAKE_TERMINAL_UP, "Snake VFX truncation rewrites the previous visible segment to the original terminal kind")
	_assert(snake_ball_hit_session.active_ball_count() == 1, "Snake VFX ball overlap does not consume the ball in this bounded VFX pass")
	_assert(snake_ball_hit_session.score == 0, "Snake VFX ball overlap does not invent score")
	_assert(snake_ball_hit_session.pop_audio_events().is_empty(), "Snake VFX ball overlap stays silent without original SFX evidence")
	var snake_ball_hit_effects: Array = snake_ball_hit_session.visible_impact_effects()
	_assert(snake_ball_hit_effects.size() == 1, "ball Snake VFX overlap spawns original kind-1 contact impact")
	if snake_ball_hit_effects.size() == 1:
		_assert(int(snake_ball_hit_effects[0]["kind"]) == GameSessionScript.IMPACT_EFFECT_KIND_SNAKE_HIT, "ball Snake VFX contact uses original kind-1 impact column")
		_assert(snake_ball_hit_effects[0]["position"] == Vector2(220, 200), "ball Snake VFX impact starts at the hit segment position")

	var snake_projectile_hit_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	snake_projectile_hit_session.force_snake_vfx_segments_for_test([
		{"position": Vector2(198, 200), "kind": 4},
		{"position": Vector2(210, 200), "kind": 5},
		{"position": Vector2(220, 200), "kind": 6},
		{"position": Vector2(232, 200), "kind": 7},
	])
	var snake_projectiles: Array[Dictionary] = [_projectile(GameSessionScript.PROJECTILE_TYPE_CONTINUOUS, Vector2(227, 200))]
	snake_projectile_hit_session.projectiles = snake_projectiles
	snake_projectile_hit_session.update(0.0)
	var snake_after_projectile_hit: Array = snake_projectile_hit_session.visible_snake_segments()
	_assert(snake_after_projectile_hit.size() == 2, "projectile overlap truncates the Snake VFX chain at the hit segment")
	if snake_after_projectile_hit.size() == 2:
		_assert(int(snake_after_projectile_hit[1]["kind"]) == GameSessionScript.SNAKE_TERMINAL_UP, "projectile Snake VFX truncation applies the original terminal rewrite")
	_assert(snake_projectile_hit_session.active_projectile_count() == 0, "projectile Snake VFX overlap consumes the projectile")
	_assert(snake_projectile_hit_session.score == 0, "projectile Snake VFX overlap does not invent score")
	_assert(snake_projectile_hit_session.pop_audio_events().is_empty(), "projectile Snake VFX overlap stays silent without original SFX evidence")
	var snake_projectile_hit_effects: Array = snake_projectile_hit_session.visible_impact_effects()
	_assert(snake_projectile_hit_effects.size() == 1, "projectile Snake VFX overlap spawns original kind-1 contact impact")
	if snake_projectile_hit_effects.size() == 1:
		_assert(int(snake_projectile_hit_effects[0]["kind"]) == GameSessionScript.IMPACT_EFFECT_KIND_SNAKE_HIT, "projectile Snake VFX contact uses original kind-1 impact column")
		_assert(snake_projectile_hit_effects[0]["position"] == Vector2(220, 200), "projectile Snake VFX impact starts at the hit segment position")

	var bee_expire_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	bee_expire_session.force_bee(Vector2(GameSessionScript.BEE_EXPIRE_X - 1.0, 100))
	bee_expire_session.update(1.0 / (GameSessionScript.BEE_STEP_X * GameSessionScript.ORIGINAL_ENEMY_UPDATE_HZ))
	_assert(bee_expire_session.active_bee_count() == 0, "bee expires at original right bound")
	_assert(bee_expire_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_BEE_STOP], "bee expiry stops EffBee playback")

	var monster_projectile_hit_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	monster_projectile_hit_session.force_monster(Vector2(200, 200), 3, 0)
	var monster_hit_projectiles: Array[Dictionary] = [_projectile(
		GameSessionScript.PROJECTILE_TYPE_CONTINUOUS,
		Vector2(200, 200)
	)]
	monster_projectile_hit_session.projectiles = monster_hit_projectiles
	monster_projectile_hit_session.update(0.0)
	_assert(monster_projectile_hit_session.active_monster_count() == 0, "projectile collision removes active monster")
	_assert(monster_projectile_hit_session.active_projectile_count() == 0, "projectile is consumed by monster collision")
	_assert(monster_projectile_hit_session.score == GameSessionScript.MONSTER_SCORE, "projectile collision awards original default monster score")
	_assert(monster_projectile_hit_session.visible_impact_effects().size() == 1, "projectile collision spawns monster hit VFX")
	var monster_projectile_audio_events: Array[String] = monster_projectile_hit_session.pop_audio_events()
	_assert(monster_projectile_audio_events.has(GameSessionScript.SFX_EVENT_PROJECTILE_HIT), "projectile monster hit queues projectile-hit SFX event")
	_assert(monster_projectile_audio_events.has(GameSessionScript.SFX_EVENT_MONSTER_HIT), "projectile monster hit queues monster-hit SFX event")

	var add_ball_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	_stack_bonus(add_ball_session, GameSessionScript.BONUS_ADD_STANDARD_BALL)
	var add_ball_result: Dictionary = add_ball_session.activate_next_bonus()
	_assert(add_ball_result["status"] == "applied", "standard-ball bonus applies")
	_assert(add_ball_result["effect"] == "add_standard_ball", "standard-ball bonus reports effect")
	_assert(add_ball_session.active_ball_count() == 2, "standard-ball bonus adds an active ball")
	_assert(add_ball_session.bonus_stack_entries().is_empty(), "applied bonus consumes first stack entry")
	var add_ball_audio_payloads: Array[Dictionary] = add_ball_session.pop_audio_event_payloads()
	_assert(_payload_events(add_ball_audio_payloads) == [GameSessionScript.SFX_EVENT_BONUS_ADD_BALL_APPLY], "standard-ball bonus queues add-ball apply SFX event")
	if add_ball_audio_payloads.size() == 1:
		_assert(is_equal_approx(float(add_ball_audio_payloads[0].get("source_x", -1.0)), float(add_ball_result.get("source_x", -2.0))), "standard-ball bonus SFX payload follows the added ball source x")

	var fireball_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	_stack_bonus(fireball_session, GameSessionScript.BONUS_ADD_FIREBALL)
	var fireball_result: Dictionary = fireball_session.activate_next_bonus()
	_assert(fireball_result["status"] == "applied", "fireball bonus applies")
	_assert(fireball_result["effect"] == "add_fireball", "fireball bonus reports effect")
	_assert(fireball_session.active_ball_count() == 2, "fireball bonus adds an active ball")
	var fireball_count := 0
	for ball: Dictionary in fireball_session.visible_balls():
		if int(ball.get("type_id", GameSessionScript.BALL_TYPE_STANDARD)) == GameSessionScript.BALL_TYPE_FIREBALL:
			fireball_count += 1
	_assert(fireball_count == 1, "fireball bonus marks exactly one added ball as fireball")
	_assert(fireball_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_BONUS_ADD_BALL_APPLY], "fireball bonus queues add-ball apply SFX event")
	while fireball_session.active_ball_count() < GameSessionScript.MAX_BALLS:
		_stack_bonus(fireball_session, GameSessionScript.BONUS_ADD_FIREBALL)
		fireball_session.activate_next_bonus()
		fireball_session.pop_audio_events()
	_stack_bonus(fireball_session, GameSessionScript.BONUS_ADD_FIREBALL)
	var capped_fireball_result: Dictionary = fireball_session.activate_next_bonus()
	_assert(not bool(capped_fireball_result["applied"]), "fireball bonus respects original five-ball pool cap")
	_assert(fireball_session.active_ball_count() == GameSessionScript.MAX_BALLS, "fireball bonus cannot overflow active balls")
	_assert(fireball_session.pop_audio_events().is_empty(), "capped fireball bonus queues no add-ball apply SFX event")

	var fireball_hard_session = _playing_session_from_level(_make_level_from_rows([[8, 1]]))
	fireball_hard_session.force_ball(
		PlayfieldSpecScript.GRID_ORIGIN + Vector2(2, 2),
		Vector2(-80, 0),
		GameSessionScript.BALL_SIZE,
		GameSessionScript.BALL_TYPE_FIREBALL
	)
	fireball_hard_session.update(0.01)
	_assert(fireball_hard_session.board_state.tile_at(0, 0) == 0, "fireball force-breaks hard brick")
	_assert(fireball_hard_session.score == GameSessionScript.HARD_BRICK_FORCE_SCORE, "fireball hard-brick hit awards original force-break score")
	_assert(fireball_hard_session.first_ball_velocity().x < 0.0, "fireball keeps moving through hard brick instead of bouncing")
	var fireball_hard_effects: Array = fireball_hard_session.visible_impact_effects()
	_assert(fireball_hard_effects.size() == 1, "fireball hard-brick hit spawns original force-break VFX")
	if fireball_hard_effects.size() == 1:
		_assert(int(fireball_hard_effects[0]["kind"]) == GameSessionScript.IMPACT_EFFECT_KIND_HARD_BRICK_FORCE_BREAK, "fireball hard-brick hit uses the original force-break VFX column")

	var fireball_pierce_session = _playing_session_from_level(_make_level_from_rows([[1, 1, 1]]))
	fireball_pierce_session.force_ball(
		PlayfieldSpecScript.GRID_ORIGIN + Vector2(22, 2),
		Vector2(-80, 0),
		GameSessionScript.BALL_SIZE,
		GameSessionScript.BALL_TYPE_FIREBALL
	)
	fireball_pierce_session.update(0.01)
	_assert(fireball_pierce_session.board_state.tile_at(1, 0) == 0, "fireball clears the first brick in its path")
	_assert(fireball_pierce_session.first_ball_velocity().x < 0.0, "fireball keeps its travel direction after the first brick")
	fireball_pierce_session.update(0.25)
	_assert(fireball_pierce_session.board_state.tile_at(0, 0) == 0, "fireball continues through and clears the next brick")
	_assert(fireball_pierce_session.first_ball_velocity().x < 0.0, "fireball remains piercing after multiple brick hits")

	var fireball_downgrade_session = _playing_session_from_level(_make_level_from_rows([[15, 1]]))
	fireball_downgrade_session.force_ball(
		PlayfieldSpecScript.GRID_ORIGIN + Vector2(2, 2),
		Vector2(-80, 0),
		GameSessionScript.BALL_SIZE,
		GameSessionScript.BALL_TYPE_FIREBALL
	)
	fireball_downgrade_session.update(0.01)
	_assert(fireball_downgrade_session.board_state.tile_at(0, 0) == 0, "fireball clears downgrade brick instead of stepping it down")
	_assert(fireball_downgrade_session.score == GameSessionScript.NORMAL_BRICK_SCORE, "fireball downgrade hit keeps original downgrade score")

	var non_stricked_session = _playing_session_from_level(_make_level_from_rows([[1, 1]]))
	non_stricked_session.force_ball(
		PlayfieldSpecScript.GRID_ORIGIN + Vector2(2, 2),
		Vector2.ZERO,
		GameSessionScript.BALL_SIZE,
		GameSessionScript.BALL_TYPE_FIREBALL
	)
	_stack_bonus(non_stricked_session, GameSessionScript.BONUS_NON_STRICKED_BALLS)
	var non_stricked_result: Dictionary = non_stricked_session.activate_next_bonus()
	_assert(non_stricked_result["status"] == "applied", "non-stricked bonus applies")
	_assert(non_stricked_result["effect"] == "non_stricked_balls", "non-stricked bonus reports effect")
	_assert(non_stricked_session.active_non_stricked_ball_count() == 1, "non-stricked bonus marks active balls")
	_assert(non_stricked_session.first_ball_type_id() == GameSessionScript.BALL_TYPE_NON_STRICKED, "non-stricked ball type is exposed")
	_assert(int(non_stricked_session.balls[0]["previous_type_id"]) == GameSessionScript.BALL_TYPE_FIREBALL, "non-stricked bonus preserves previous fireball type")
	non_stricked_session.update(0.01)
	_assert(non_stricked_session.board_state.tile_at(0, 0) == 1, "non-stricked balls pass through board bricks")
	_assert(non_stricked_session.score == 0, "non-stricked board pass-through awards no score")
	_assert(not non_stricked_session.consume_board_changed(), "non-stricked board pass-through does not redraw the board")
	_stack_bonus(non_stricked_session, GameSessionScript.BONUS_NON_STRICKED_BALLS)
	non_stricked_session.activate_next_bonus()
	_assert(int(non_stricked_session.balls[0]["previous_type_id"]) == GameSessionScript.BALL_TYPE_FIREBALL, "reapplying non-stricked preserves original previous type")
	_assert(is_equal_approx(float(non_stricked_session.balls[0]["non_stricked_time_remaining"]), GameSessionScript.NON_STRICKED_DURATION_SECONDS), "reapplying non-stricked resets the original timer")
	non_stricked_session.force_ball(
		Vector2(300, 200),
		Vector2.ZERO,
		GameSessionScript.BALL_SIZE,
		GameSessionScript.BALL_TYPE_FIREBALL
	)
	_stack_bonus(non_stricked_session, GameSessionScript.BONUS_NON_STRICKED_BALLS)
	non_stricked_session.activate_next_bonus()
	non_stricked_session.update(GameSessionScript.NON_STRICKED_DURATION_SECONDS)
	_assert(non_stricked_session.first_ball_type_id() == GameSessionScript.BALL_TYPE_FIREBALL, "non-stricked expiry restores previous fireball type")

	var one_strike_session = _playing_session_from_level(_make_level_from_rows([[8, 15, 40, 39, 42, 69, 70, 71, 101, 133, 137, 139, 141, 143, 145, 1]]))
	_stack_bonus(one_strike_session, GameSessionScript.BONUS_ONE_STRIKE_BRICKS)
	var one_strike_result: Dictionary = one_strike_session.activate_next_bonus()
	_assert(one_strike_result["status"] == "applied", "one-strike bonus applies")
	_assert(one_strike_result["effect"] == "one_strike_bricks", "one-strike bonus reports effect")
	_assert(int(one_strike_result["changed"]) == 15, "one-strike bonus weakens mapped board tiles")
	_assert(one_strike_session.score == 0, "one-strike bonus does not award score by itself")
	_assert(one_strike_session.consume_board_changed(), "one-strike bonus marks the board dirty")
	_assert(one_strike_session.board_state.tile_at(0, 0) == 7, "one-strike session maps tile 8 to 7")
	_assert(one_strike_session.board_state.tile_at(1, 0) == 14, "one-strike session maps tile 15 to 14")
	_assert(one_strike_session.board_state.tile_at(2, 0) == 14, "one-strike session maps tile 40 to 14")
	_assert(one_strike_session.board_state.tile_at(3, 0) == 37, "one-strike session maps tile 39 to 37")
	_assert(one_strike_session.board_state.tile_at(4, 0) == 44, "one-strike session maps tile 42 to 44")
	_assert(one_strike_session.board_state.tile_at(5, 0) == 32, "one-strike session maps tile 69 to 32")
	_assert(one_strike_session.board_state.tile_at(6, 0) == 24, "one-strike session maps tile 70 to 24")
	_assert(one_strike_session.board_state.tile_at(7, 0) == 16, "one-strike session maps tile 71 to 16")
	_assert(one_strike_session.board_state.tile_at(8, 0) == 67, "one-strike session maps tile 101 to 67")
	_assert(one_strike_session.board_state.tile_at(9, 0) == 132, "one-strike session maps tile 133 to 132")
	_assert(one_strike_session.board_state.tile_at(10, 0) == 136, "one-strike session maps tile 137 to 136")
	_assert(one_strike_session.board_state.tile_at(11, 0) == 138, "one-strike session maps tile 139 to 138")
	_assert(one_strike_session.board_state.tile_at(12, 0) == 140, "one-strike session maps tile 141 to 140")
	_assert(one_strike_session.board_state.tile_at(13, 0) == 142, "one-strike session maps tile 143 to 142")
	_assert(one_strike_session.board_state.tile_at(14, 0) == 144, "one-strike session maps tile 145 to 144")
	_assert(one_strike_session.board_state.tile_at(15, 0) == 1, "one-strike session leaves ordinary tile 1 unchanged")

	var random_bonus_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	random_bonus_session.set_bonus_rng_seed(9)
	_stack_bonus(random_bonus_session, GameSessionScript.BONUS_RANDOM_BONUS)
	var random_bonus_result: Dictionary = random_bonus_session.activate_next_bonus()
	_assert(random_bonus_result["status"] == "applied", "random bonus applies")
	_assert(random_bonus_result["effect"] == "random_bonus", "random bonus reports effect")
	_assert(int(random_bonus_result["selected_type_id"]) == GameSessionScript.BONUS_EXTRA_LIFE, "random bonus uses the original LCG selection")
	_assert(random_bonus_session.bonus_stack_entries().size() == 1, "random bonus appends the selected bonus after consuming itself")
	_assert(int(random_bonus_session.bonus_stack_entries()[0]["type_id"]) == GameSessionScript.BONUS_EXTRA_LIFE, "random bonus stacks the selected item without applying it")
	_assert(random_bonus_session.lives_remaining == GameSessionScript.INITIAL_LIVES, "random-selected extra life waits for a second activation")
	random_bonus_session.activate_next_bonus()
	_assert(random_bonus_session.lives_remaining == GameSessionScript.INITIAL_LIVES + 1, "random-selected stacked bonus can be activated normally")

	var random_double_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	random_double_session.set_bonus_rng_seed(8)
	_stack_bonus(random_double_session, GameSessionScript.BONUS_RANDOM_BONUS)
	var random_double_result: Dictionary = random_double_session.activate_next_bonus()
	_assert(int(random_double_result["selected_type_id"]) == GameSessionScript.BONUS_DOUBLE_PADDLE, "random bonus can select double-paddle original item")
	_assert(int(random_double_session.bonus_stack_entries()[0]["type_id"]) == GameSessionScript.BONUS_DOUBLE_PADDLE, "random double result remains stacked for later activation")
	var random_double_apply_result: Dictionary = random_double_session.activate_next_bonus()
	_assert(random_double_apply_result["effect"] == "double_paddle", "random-selected double paddle can be activated normally")
	_assert(random_double_session.is_double_paddle_active(), "random-selected double paddle enables the secondary racket")

	var random_reroll_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	random_reroll_session.set_bonus_rng_seed(29)
	_stack_bonus(random_reroll_session, GameSessionScript.BONUS_RANDOM_BONUS)
	var random_reroll_result: Dictionary = random_reroll_session.activate_next_bonus()
	_assert(int(random_reroll_result["selected_type_id"]) == GameSessionScript.BONUS_EXPAND_EXPLODING, "random bonus rerolls when it selects itself")
	_assert(int(random_reroll_session.bonus_stack_entries()[0]["type_id"]) == GameSessionScript.BONUS_EXPAND_EXPLODING, "rerolled random bonus stacks the replacement item")

	var expand_exploding_session = _playing_session_from_level(_make_level_from_rows([
		[0, 0, 0, 0],
		[0, 43, 0, 0],
		[0, 0, 0, 0],
		[0, 0, 0, 0],
	]))
	_stack_bonus(expand_exploding_session, GameSessionScript.BONUS_EXPAND_EXPLODING)
	var expand_exploding_result: Dictionary = expand_exploding_session.activate_next_bonus()
	_assert(expand_exploding_result["status"] == "applied", "expand-exploding bonus applies")
	_assert(expand_exploding_result["effect"] == "expand_exploding", "expand-exploding bonus reports effect")
	_assert(int(expand_exploding_result["changed"]) == 8, "expand-exploding bonus spreads from the original chain-tile snapshot")
	_assert(expand_exploding_session.consume_board_changed(), "expand-exploding bonus marks board dirty")
	_assert(expand_exploding_session.score == 0, "expand-exploding bonus does not award score by itself")
	for expand_row in range(3):
		for expand_column in range(3):
			_assert(expand_exploding_session.board_state.tile_at(expand_column, expand_row) == 43, "expand-exploding fills the original 3x3 neighborhood")
	_assert(expand_exploding_session.board_state.tile_at(3, 3) == 0, "expand-exploding does not cascade from newly-created chain tiles")

	var explode_all_session = _playing_session_from_level(_make_level_from_rows([
		[43, 0, 0, 0],
		[0, 0, 0, 0],
		[0, 0, 68, 1],
	]))
	_stack_bonus(explode_all_session, GameSessionScript.BONUS_EXPLODE_ALL_EXPLODINGS)
	var explode_all_result: Dictionary = explode_all_session.activate_next_bonus()
	_assert(explode_all_result["status"] == "applied", "explode-all-explodings bonus applies")
	_assert(explode_all_result["effect"] == "explode_all_explodings", "explode-all-explodings bonus reports effect")
	_assert(int(explode_all_result["scheduled"]) == 2, "explode-all-explodings schedules every current chain tile")
	_assert(explode_all_session.board_state.pending_chain_explosion_count() == 2, "scheduled chain tiles wait for the normal delay")
	_assert(explode_all_session.score == 0, "explode-all-explodings does not score before delayed resolution")
	explode_all_session.update(0.031)
	_assert(explode_all_session.board_state.tile_at(0, 0) == 0, "explode-all clears the first scheduled chain tile")
	_assert(explode_all_session.board_state.tile_at(2, 2) == 0, "explode-all clears the second scheduled chain tile")
	_assert(explode_all_session.board_state.tile_at(3, 2) == 0, "explode-all chain resolution clears neighboring active bricks")
	_assert(explode_all_session.score == GameSessionScript.CHAIN_BRICK_SCORE * 3, "explode-all scoring follows delayed chain clears")
	var explode_all_audio_events: Array[String] = explode_all_session.pop_audio_events()
	_assert(explode_all_audio_events.has(GameSessionScript.SFX_EVENT_CHAIN_EXPLOSION), "explode-all delayed clear queues chain-explosion SFX event")

	var stack_shift_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	_stack_bonus(stack_shift_session, GameSessionScript.BONUS_EXTRA_LIFE)
	_stack_bonus(stack_shift_session, GameSessionScript.BONUS_JUMP_TO_NEXT_LEVEL)
	stack_shift_session.activate_next_bonus()
	_assert(stack_shift_session.bonus_stack_entries().size() == 1, "applied bonus shifts stack left")
	_assert(int(stack_shift_session.bonus_stack_entries()[0]["type_id"]) == GameSessionScript.BONUS_JUMP_TO_NEXT_LEVEL, "stack shift preserves next bonus")

	var ball_size_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	_stack_bonus(ball_size_session, GameSessionScript.BONUS_INCREASE_BALL_SIZE)
	ball_size_session.activate_next_bonus()
	_assert(ball_size_session.ball_size == 26.0, "increase-size bonus grows current ball size by original atlas step")
	_assert(ball_size_session.ball_rect(ball_size_session.visible_balls()[0]).size == Vector2(26, 26), "increase-size bonus updates live ball rect")
	for size_index in range(3):
		_stack_bonus(ball_size_session, GameSessionScript.BONUS_DECREASE_BALL_SIZE)
		ball_size_session.activate_next_bonus()
	_assert(ball_size_session.ball_size == GameSessionScript.BALL_MIN_SIZE, "decrease-size bonus clamps at original minimum")

	var ball_speed_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	ball_speed_session.force_ball(Vector2(300, 200), Vector2(-200, 0))
	_stack_bonus(ball_speed_session, GameSessionScript.BONUS_INCREASE_BALL_SPEED)
	ball_speed_session.activate_next_bonus()
	_assert(ball_speed_session.ball_speed_scale == 3.0, "increase-speed bonus increments original speed scalar")
	_assert(is_equal_approx(ball_speed_session.first_ball_velocity().length(), 300.0), "increase-speed bonus scales live velocity")
	for speed_index in range(2):
		_stack_bonus(ball_speed_session, GameSessionScript.BONUS_DECREASE_BALL_SPEED)
		ball_speed_session.activate_next_bonus()
	_assert(ball_speed_session.ball_speed_scale == GameSessionScript.BALL_MIN_SPEED_SCALE, "decrease-speed bonus clamps at original minimum")
	_assert(is_equal_approx(ball_speed_session.first_ball_velocity().length(), 200.0), "decrease-speed bonus restores minimum velocity scale")

	var racket_size_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	_stack_bonus(racket_size_session, GameSessionScript.BONUS_EXPAND_PADDLE)
	racket_size_session.activate_next_bonus()
	_assert(racket_size_session.racket_segment_count == GameSessionScript.RACKET_DEFAULT_SEGMENTS + GameSessionScript.RACKET_BONUS_STEP_SEGMENTS, "expand-paddle bonus uses original segment step")
	_assert(racket_size_session.current_racket_height() == 89.0, "expand-paddle bonus updates racket height from segment count")
	_stack_bonus(racket_size_session, GameSessionScript.BONUS_SHRINK_PADDLE)
	racket_size_session.activate_next_bonus()
	_assert(racket_size_session.current_racket_height() == GameSessionScript.RACKET_HEIGHT, "shrink-paddle bonus can return to default height")
	for shrink_index in range(4):
		_stack_bonus(racket_size_session, GameSessionScript.BONUS_SHRINK_PADDLE)
		racket_size_session.activate_next_bonus()
	_assert(racket_size_session.racket_segment_count == GameSessionScript.RACKET_MIN_SEGMENTS, "shrink-paddle bonus reaches original reachable minimum")
	_assert(racket_size_session.current_racket_height() == 29.0, "minimum racket size uses original collision formula")
	for expand_index in range(20):
		_stack_bonus(racket_size_session, GameSessionScript.BONUS_EXPAND_PADDLE)
		racket_size_session.activate_next_bonus()
	_assert(racket_size_session.racket_segment_count == GameSessionScript.RACKET_MAX_SEGMENTS, "expand-paddle bonus reaches original reachable maximum")
	_assert(racket_size_session.current_racket_height() == 209.0, "maximum racket size uses original collision formula")

	var double_paddle_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	double_paddle_session.move_racket_to(220.0, 300.0)
	_stack_bonus(double_paddle_session, GameSessionScript.BONUS_DOUBLE_PADDLE)
	var double_paddle_result: Dictionary = double_paddle_session.activate_next_bonus()
	_assert(double_paddle_result["status"] == "applied", "double-paddle bonus applies")
	_assert(double_paddle_result["effect"] == "double_paddle", "double-paddle bonus reports effect")
	_assert(double_paddle_session.is_double_paddle_active(), "double-paddle bonus enables the secondary racket")
	var double_racket_rects: Array[Rect2] = double_paddle_session.racket_rects()
	_assert(double_racket_rects.size() == 2, "double-paddle exposes two racket rectangles")
	if double_racket_rects.size() == 2:
		_assert(double_racket_rects[1].position.x == GameSessionScript.RACKET_X + GameSessionScript.DOUBLE_PADDLE_OFFSET_X, "double-paddle secondary racket uses original x offset")
		double_paddle_session.move_racket_to(220.0, 290.0)
		double_racket_rects = double_paddle_session.racket_rects()
		_assert(double_racket_rects[1].position.x == GameSessionScript.RACKET_X + GameSessionScript.DOUBLE_PADDLE_OFFSET_X - 20.0, "double-paddle secondary racket follows doubled mouse-x deltas")
		double_paddle_session.move_racket_to(220.0, -1000.0)
		double_racket_rects = double_paddle_session.racket_rects()
		_assert(double_racket_rects[1].position.x == GameSessionScript.DOUBLE_PADDLE_MIN_X, "double-paddle secondary racket clamps at original left bound")
		double_paddle_session.move_racket_to(220.0, 1000.0)
		double_racket_rects = double_paddle_session.racket_rects()
		_assert(double_racket_rects[1].position.x == GameSessionScript.RACKET_X + GameSessionScript.DOUBLE_PADDLE_OFFSET_X, "double-paddle secondary racket clamps before the primary racket")
		double_paddle_session.force_ball(
			Vector2(double_racket_rects[1].position.x - GameSessionScript.BALL_SIZE + 1.0, double_racket_rects[1].position.y + 20.0),
			Vector2(200, 0)
		)
		double_paddle_session.update(0.0)
		_assert(double_paddle_session.first_ball_velocity().x < 0.0, "double-paddle secondary racket bounces a right-moving ball")
		_assert(is_equal_approx(double_paddle_session.first_ball_position().x, double_racket_rects[1].position.x - GameSessionScript.BALL_SIZE), "double-paddle bounce resolves at secondary racket face")

	var magnet_paddle_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	magnet_paddle_session.move_racket_to(220.0)
	_stack_bonus(magnet_paddle_session, GameSessionScript.BONUS_MAGNET_PADDLE)
	var magnet_paddle_result: Dictionary = magnet_paddle_session.activate_next_bonus()
	_assert(magnet_paddle_result["status"] == "applied", "magnet-paddle bonus applies")
	_assert(magnet_paddle_result["effect"] == "magnet_paddle", "magnet-paddle bonus reports effect")
	_assert(magnet_paddle_session.is_magnet_paddle_active(), "magnet-paddle bonus enables sticky racket state")
	_assert(magnet_paddle_session.current_racket_visual_mode() == GameSessionScript.RACKET_VISUAL_MODE_MAGNET, "magnet-paddle bonus switches racket to original magnet insert")
	_assert(magnet_paddle_session.current_racket_visual_frame() == 0, "magnet-paddle insert starts at first original frame")
	magnet_paddle_session.force_ball(Vector2(300, 200), Vector2.ZERO)
	magnet_paddle_session._monster_spawn_cooldown = 999.0
	magnet_paddle_session._bee_spawn_delay_remaining = 999.0
	magnet_paddle_session.update(GameSessionScript.RACKET_VISUAL_FRAME_SECONDS)
	_assert(magnet_paddle_session.current_racket_visual_frame() == 1, "magnet-paddle insert advances through original 50 ms frames")
	for magnet_frame_index in range(GameSessionScript.RACKET_MAGNET_VISUAL_FRAME_COUNT - 1):
		magnet_paddle_session.update(GameSessionScript.RACKET_VISUAL_FRAME_SECONDS)
	_assert(magnet_paddle_session.current_racket_visual_frame() == 0, "magnet-paddle insert loops while the sticky racket is active")
	var magnet_racket_rect: Rect2 = magnet_paddle_session.racket_rect()
	magnet_paddle_session.force_ball(
		Vector2(GameSessionScript.RACKET_X - GameSessionScript.BALL_SIZE + 1.0, magnet_racket_rect.position.y + 20.0),
		Vector2(200, 0)
	)
	magnet_paddle_session.update(0.0)
	_assert(magnet_paddle_session.magnet_attached_ball_count() == 1, "magnet-paddle catches a right-moving ball")
	_assert(magnet_paddle_session.first_ball_velocity() == Vector2.ZERO, "magnet-attached ball stops until release")
	var magnet_attached_start_y: float = magnet_paddle_session.first_ball_position().y
	magnet_paddle_session.move_racket_to(260.0)
	_assert(is_equal_approx(magnet_paddle_session.first_ball_position().y, magnet_attached_start_y), "magnet-attached ball waits for session updates after racket movement")
	var magnet_center_target_y: float = magnet_paddle_session.racket_rect().position.y \
		+ (magnet_paddle_session.current_racket_height() - GameSessionScript.BALL_SIZE) * 0.5
	magnet_paddle_session.update(0.1)
	var magnet_delayed_y: float = magnet_paddle_session.first_ball_position().y
	_assert(magnet_delayed_y > magnet_attached_start_y, "magnet-attached ball moves toward the racket center after delay")
	_assert(magnet_delayed_y < magnet_center_target_y, "magnet-attached ball does not snap directly to the racket center")
	magnet_paddle_session.update(1.0)
	_assert(is_equal_approx(magnet_paddle_session.first_ball_position().y, magnet_center_target_y), "magnet-attached ball eventually reaches the racket center")
	_assert(magnet_paddle_session.launch_ready_ball(), "left-click launch releases magnet-attached balls during play")
	_assert(magnet_paddle_session.magnet_attached_ball_count() == 0, "magnet release clears attached state")
	_assert(magnet_paddle_session.first_ball_velocity().x < 0.0, "magnet release sends ball back into the board")
	_assert(is_equal_approx(magnet_paddle_session.first_ball_velocity().length(), 200.0), "magnet release preserves stored ball speed")

	var drunk_paddle_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	drunk_paddle_session.move_racket_to(220.0)
	var sober_center_y: float = drunk_paddle_session.racket_rect().get_center().y
	_stack_bonus(drunk_paddle_session, GameSessionScript.BONUS_DRUNK_PADDLE)
	var drunk_paddle_result: Dictionary = drunk_paddle_session.activate_next_bonus()
	_assert(drunk_paddle_result["status"] == "applied", "drunk-paddle bonus applies")
	_assert(drunk_paddle_result["effect"] == "drunk_paddle", "drunk-paddle bonus reports effect")
	_assert(drunk_paddle_session.is_drunk_paddle_active(), "drunk-paddle bonus starts timed inverted movement")
	drunk_paddle_session.move_racket_to(260.0)
	_assert(is_equal_approx(drunk_paddle_session.racket_rect().get_center().y, sober_center_y - 40.0), "drunk-paddle inverts mouse movement delta")
	drunk_paddle_session.force_ball(Vector2(300, 200), Vector2.ZERO)
	drunk_paddle_session._monster_spawn_cooldown = 999.0
	drunk_paddle_session._bee_spawn_delay_remaining = 999.0
	drunk_paddle_session.update(10.0)
	_stack_bonus(drunk_paddle_session, GameSessionScript.BONUS_DRUNK_PADDLE)
	var repeated_drunk_result: Dictionary = drunk_paddle_session.activate_next_bonus()
	_assert(is_equal_approx(float(repeated_drunk_result["seconds_remaining"]), 50.0), "repeated drunk-paddle activation adds original duration")
	drunk_paddle_session.update(50.0)
	_assert(not drunk_paddle_session.is_drunk_paddle_active(), "drunk-paddle timer expires")
	drunk_paddle_session.move_racket_to(300.0)
	_assert(is_equal_approx(drunk_paddle_session.racket_rect().get_center().y, 300.0), "expired drunk-paddle restores absolute mouse movement")

	var extra_life_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	_stack_bonus(extra_life_session, GameSessionScript.BONUS_EXTRA_LIFE)
	extra_life_session.activate_next_bonus()
	_assert(extra_life_session.lives_remaining == GameSessionScript.INITIAL_LIVES + 1, "extra-life bonus increments spare balls")

	var destroy_ball_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	_stack_bonus(destroy_ball_session, GameSessionScript.BONUS_ADD_STANDARD_BALL)
	destroy_ball_session.activate_next_bonus()
	destroy_ball_session.pop_audio_events()
	var removed_ball_position: Vector2 = destroy_ball_session.visible_balls()[0].get("position", Vector2.ZERO)
	_stack_bonus(destroy_ball_session, GameSessionScript.BONUS_DESTROY_ONE_BALL)
	var destroy_ball_result: Dictionary = destroy_ball_session.activate_next_bonus()
	_assert(bool(destroy_ball_result["applied"]), "destroy-ball bonus removes an active ball when one exists")
	_assert(destroy_ball_result["effect"] == "destroy_one_ball", "destroy-ball bonus reports effect")
	_assert(destroy_ball_session.active_ball_count() == 1, "destroy-ball bonus removes one active ball")
	_assert(
		destroy_ball_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_BONUS_DESTROY_BALL_APPLY],
		"destroy-ball bonus queues dedicated eff24 apply SFX event"
	)
	var destroy_ball_effects: Array = destroy_ball_session.visible_impact_effects()
	_assert(destroy_ball_effects.size() == 1, "destroy-ball bonus spawns one shared explosion VFX")
	if destroy_ball_effects.size() == 1:
		_assert(
			int(destroy_ball_effects[0]["kind"]) == GameSessionScript.IMPACT_EFFECT_KIND_EXPLOSION,
			"destroy-ball bonus reuses the original explosion effect kind"
		)
		_assert(
			destroy_ball_effects[0]["position"] == removed_ball_position,
			"destroy-ball bonus spawns the explosion at the removed ball position"
		)

	var failed_destroy_ball_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	failed_destroy_ball_session.balls.clear()
	_stack_bonus(failed_destroy_ball_session, GameSessionScript.BONUS_DESTROY_ONE_BALL)
	var failed_destroy_ball_result: Dictionary = failed_destroy_ball_session.activate_next_bonus()
	_assert(not bool(failed_destroy_ball_result["applied"]), "destroy-ball bonus reports failure when no active ball exists")
	_assert(failed_destroy_ball_session.pop_audio_events().is_empty(), "failed destroy-ball bonus stays silent")
	_assert(failed_destroy_ball_session.visible_impact_effects().is_empty(), "failed destroy-ball bonus spawns no VFX")

	var back_wall_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	_stack_bonus(back_wall_session, GameSessionScript.BONUS_BACK_WALL)
	var back_wall_result: Dictionary = back_wall_session.activate_next_bonus()
	_assert(back_wall_result["status"] == "applied", "back-wall bonus applies")
	_assert(back_wall_result["effect"] == "back_wall", "back-wall bonus reports effect")
	_assert(back_wall_session.is_back_wall_active(), "back-wall bonus starts timed wall")
	_assert(back_wall_session.bonus_stack_entries().is_empty(), "back-wall bonus consumes first stack entry")
	var back_wall_indicators: Array = back_wall_session.active_bonus_indicators()
	_assert(back_wall_indicators.size() == 1, "back-wall bonus exposes one active status indicator")
	if back_wall_indicators.size() == 1:
		_assert(int(back_wall_indicators[0]["icon_index"]) == GameSessionScript.BACK_WALL_STATUS_ICON_INDEX, "back-wall status uses original wall icon slot")
		_assert(int(back_wall_indicators[0]["value"]) == int(GameSessionScript.BACK_WALL_DURATION_SECONDS), "back-wall status starts at original duration")
	back_wall_session.force_ball(
		Vector2(GameSessionScript.BACK_WALL_BOUNCE_X - GameSessionScript.BALL_SIZE - 1.0, 350),
		Vector2(200, 0)
	)
	back_wall_session.update(0.01)
	_assert(back_wall_session.state == GameSessionScript.STATE_PLAYING, "back wall prevents right-side ball loss")
	_assert(back_wall_session.first_ball_velocity().x < 0.0, "back wall reflects missed ball")
	_assert(back_wall_session.pop_audio_events().has(GameSessionScript.SFX_EVENT_BACK_WALL_BOUNCE), "back wall reflection queues semantic SFX event")
	back_wall_session.force_ball(Vector2(300, 200), Vector2.ZERO)
	back_wall_session.update(GameSessionScript.BACK_WALL_DURATION_SECONDS)
	_assert(not back_wall_session.is_back_wall_active(), "back wall expires after original duration")
	_assert(back_wall_session.active_bonus_indicators().is_empty(), "expired back wall clears status indicator")
	back_wall_session.force_ball(Vector2(GameSessionScript.BALL_LOST_X + 1.0, 350), Vector2(120, 0))
	back_wall_session.update(0.01)
	_assert(back_wall_session.state == GameSessionScript.STATE_READY, "right-side miss is lost after back wall expires")

	var jump_level_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	_stack_bonus(jump_level_session, GameSessionScript.BONUS_JUMP_TO_NEXT_LEVEL)
	jump_level_session.activate_next_bonus()
	_assert(jump_level_session.state == GameSessionScript.STATE_LEVEL_COMPLETE, "jump-level bonus routes through level-complete state")
	_assert(jump_level_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_BONUS_JUMP_LEVEL_APPLY], "jump-level bonus queues dedicated jump-level apply SFX event")


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
	_assert(renderer.current_reveal_offset_pixels() == -1.0, "level renderer draws all columns without a ready reveal")
	_assert(renderer.is_column_revealed(19), "level renderer shows the full board by default")
	renderer.set_reveal_offset_pixels(0.0)
	_assert(renderer.is_column_revealed(0), "level renderer reveals the first brick column at the roller start")
	_assert(not renderer.is_column_revealed(1), "level renderer hides the right side before the roller reaches it")
	renderer.set_reveal_offset_pixels(GameSessionScript.LEVEL_READY_ROLLER_STEP_PIXELS)
	_assert(renderer.is_column_revealed(0), "level renderer keeps only the first column after one roller step")
	_assert(not renderer.is_column_revealed(1), "level renderer waits for the roller to reach the next column")
	renderer.set_reveal_offset_pixels(PlayfieldSpecScript.BRICK_SIZE.x)
	_assert(renderer.is_column_revealed(1), "level renderer reveals a new column when the roller reaches it")
	renderer.set_reveal_offset_pixels(-1.0)
	_assert(renderer.is_column_revealed(19), "level renderer restores the full board after the ready reveal finishes")
	renderer.free()

	var ball_renderer: KrakoutBallRenderer = BallRendererScript.new()
	_assert(ball_renderer.source_rect_for_size(10.0, 0) == Rect2(Vector2(1, 1), Vector2(10, 10)), "ball renderer maps smallest atlas row")
	_assert(ball_renderer.source_rect_for_size(GameSessionScript.BALL_SIZE, 0) == Rect2(Vector2(1, 13), Vector2(18, 18)), "ball renderer maps default standard ball atlas row")
	_assert(ball_renderer.source_rect_for_size(26.0, 2) == Rect2(Vector2(57, 33), Vector2(26, 26)), "ball renderer maps increased ball frame")
	_assert(ball_renderer.source_rect_for_size(GameSessionScript.BALL_MAX_SIZE, 9) == Rect2(Vector2(397, 97), Vector2(42, 42)), "ball renderer maps largest atlas row")
	_assert(BallRendererScript.fireball_source_rect(0) == Rect2(Vector2(0, 0), Vector2(24, 24)), "ball renderer maps first fireball frame from Fb sheet")
	_assert(BallRendererScript.fireball_source_rect(5) == Rect2(Vector2(0, 120), Vector2(24, 24)), "ball renderer maps final fireball frame from Fb sheet")
	_assert(BallRendererScript.fireball_source_rect(6) == Rect2(Vector2(0, 0), Vector2(24, 24)), "ball renderer wraps fireball frames")
	_assert(BallRendererScript.modulate_for_ball_type(GameSessionScript.BALL_TYPE_STANDARD) == Color.WHITE, "standard balls draw with original atlas color")
	_assert(BallRendererScript.modulate_for_ball_type(GameSessionScript.BALL_TYPE_FIREBALL) == BallRendererScript.FIREBALL_BALL_MODULATE, "fireballs tint the base ball toward the original warm Fb colors")
	_assert(BallRendererScript.modulate_for_ball_type(GameSessionScript.BALL_TYPE_NON_STRICKED) == BallRendererScript.NON_STRICKED_BALL_MODULATE, "non-stricked balls draw with a distinct tint")
	_assert(BallRendererScript.source_size_for_ball_type(GameSessionScript.BALL_TYPE_FIREBALL, GameSessionScript.BALL_SIZE) == BallRendererScript.FIREBALL_FRAME_SIZE.x, "fireballs use the native Fb footprint instead of the smaller default ball size")
	_assert(BallRendererScript.visual_rect_for_ball_type(GameSessionScript.BALL_TYPE_FIREBALL, Rect2(Vector2(10, 20), Vector2(18, 18))) == Rect2(Vector2(7, 17), Vector2(24, 24)), "fireballs center the native Fb sprite over the gameplay ball")
	_assert(BallRendererScript.FIREBALL_EFFECT_MODULATE == Color.WHITE, "fireballs preserve the extracted Fb sheet colors and alpha")
	_assert(BallRendererScript.BALL_TRACKS_DRAW_OVER_BALLS, "ball tracks are composited over the ball sprite like the original")
	_assert(BallRendererScript.ball_track_source_rect(GameSessionScript.BALL_TYPE_STANDARD, 0) == Rect2(Vector2(12, 0), Vector2(12, 12)), "standard ball tracks draw from the original Fb second column")
	_assert(BallRendererScript.ball_track_source_rect(GameSessionScript.BALL_TYPE_FIREBALL, 11) == Rect2(Vector2(0, 132), Vector2(12, 12)), "fireball tracks draw from the original Fb first column and twelfth frame")
	var hidden_ball_session = _game_session_from_level(_make_level_from_rows([[1]]))
	hidden_ball_session.start_level_ready_sequence(false)
	ball_renderer.set_session(hidden_ball_session)
	_assert(not ball_renderer.are_balls_visible_for_session(), "ball renderer hides the ready ball while the ready roller is visible")
	hidden_ball_session.update(GameSessionScript.LEVEL_READY_ANIMATION_SECONDS)
	_assert(ball_renderer.are_balls_visible_for_session(), "ball renderer restores the ready ball after the ready roller finishes")
	ball_renderer.free()

	var racket_regions: Array[Dictionary] = RacketRendererScript.draw_regions_for_rect(
		Rect2(Vector2(GameSessionScript.RACKET_X, 221), Vector2(GameSessionScript.RACKET_WIDTH, GameSessionScript.RACKET_HEIGHT)),
		GameSessionScript.RACKET_DEFAULT_SEGMENTS
	)
	_assert(racket_regions.size() == 4, "racket renderer composes the original base strip plus centered insert")
	if racket_regions.size() == 4:
		_assert(racket_regions[0]["source"] == RacketRendererScript.TOP_SOURCE_RECT, "racket renderer maps original top cap")
		_assert(racket_regions[0]["dest"] == Rect2(Vector2(GameSessionScript.RACKET_X, 221), Vector2(16, 11)), "racket renderer draws top cap unscaled")
		_assert(racket_regions[1]["source"] == Rect2(Vector2(0, 11), Vector2(16, 50)), "racket renderer maps default body segment range")
		_assert(racket_regions[1]["dest"] == Rect2(Vector2(GameSessionScript.RACKET_X, 232), Vector2(16, 50)), "racket renderer draws default body without full-strip scaling")
		_assert(racket_regions[2]["source"] == RacketRendererScript.BOTTOM_SOURCE_RECT, "racket renderer maps original bottom cap")
		_assert(racket_regions[2]["dest"] == Rect2(Vector2(GameSessionScript.RACKET_X, 282), Vector2(16, 12)), "racket renderer draws bottom cap unscaled")
		_assert(racket_regions[3]["source"] == RacketRendererScript.NORMAL_INSERT_SOURCE_RECT, "racket renderer maps the original normal insert")
		_assert(racket_regions[3]["dest"] == Rect2(Vector2(GameSessionScript.RACKET_X + 1.0, 239), Vector2(31, 36)), "racket renderer centers the original normal insert")
	var continuous_region: Dictionary = RacketRendererScript.overlay_region_for_rect(
		Rect2(Vector2(GameSessionScript.RACKET_X, 221), Vector2(GameSessionScript.RACKET_WIDTH, GameSessionScript.RACKET_HEIGHT)),
		GameSessionScript.RACKET_DEFAULT_SEGMENTS,
		GameSessionScript.RACKET_VISUAL_MODE_SHOOTING_CONTINUOUS,
		GameSessionScript.RACKET_VISUAL_MAX_FRAME
	)
	_assert(continuous_region["source"] == Rect2(Vector2(169, 37), Vector2(38, 36)), "racket renderer maps the original continuous launcher final frame")
	_assert(continuous_region["dest"] == Rect2(Vector2(GameSessionScript.RACKET_X - 11.0, 239), Vector2(38, 36)), "racket renderer centers the continuous launcher insert")
	var single_shot_region: Dictionary = RacketRendererScript.overlay_region_for_rect(
		Rect2(Vector2(GameSessionScript.RACKET_X, 221), Vector2(GameSessionScript.RACKET_WIDTH, GameSessionScript.RACKET_HEIGHT)),
		GameSessionScript.RACKET_DEFAULT_SEGMENTS,
		GameSessionScript.RACKET_VISUAL_MODE_SHOOTING_ONE_SHOT,
		GameSessionScript.RACKET_VISUAL_MAX_FRAME
	)
	_assert(single_shot_region["source"] == Rect2(Vector2(169, 74), Vector2(38, 36)), "racket renderer maps the original single-shot launcher final frame")
	var magnet_region: Dictionary = RacketRendererScript.overlay_region_for_rect(
		Rect2(Vector2(GameSessionScript.RACKET_X, 221), Vector2(GameSessionScript.RACKET_WIDTH, GameSessionScript.RACKET_HEIGHT)),
		GameSessionScript.RACKET_DEFAULT_SEGMENTS,
		GameSessionScript.RACKET_VISUAL_MODE_MAGNET,
		GameSessionScript.RACKET_MAGNET_VISUAL_FRAME_COUNT - 1
	)
	_assert(magnet_region["source"] == Rect2(Vector2(167, 171), Vector2(30, 30)), "racket renderer maps the original magnet insert final frame")
	_assert(magnet_region["dest"] == Rect2(Vector2(GameSessionScript.RACKET_X + 15.0, 242), Vector2(30, 30)), "racket renderer positions the original magnet insert behind the paddle")
	var ready_racket_renderer: KrakoutRacketRenderer = RacketRendererScript.new()
	var hidden_racket_session = _game_session_from_level(_make_level_from_rows([[1]]))
	hidden_racket_session.start_level_ready_sequence(false)
	ready_racket_renderer.set_session(hidden_racket_session)
	_assert(not ready_racket_renderer.is_racket_visible_for_session(), "racket renderer hides the paddle while the ready roller is visible")
	hidden_racket_session.update(GameSessionScript.LEVEL_READY_ANIMATION_SECONDS)
	_assert(ready_racket_renderer.is_racket_visible_for_session(), "racket renderer restores the paddle after the ready roller finishes")
	ready_racket_renderer.free()

	var double_racket_renderer: KrakoutRacketRenderer = RacketRendererScript.new()
	var double_racket_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	_stack_bonus(double_racket_session, GameSessionScript.BONUS_DOUBLE_PADDLE)
	double_racket_session.activate_next_bonus()
	double_racket_renderer.set_session(double_racket_session)
	var renderer_racket_rects: Array = double_racket_renderer.call("_racket_rects_for_session")
	_assert(renderer_racket_rects.size() == 2, "racket renderer reads every visible double-paddle rectangle")
	double_racket_renderer.free()

	var bullet_renderer: KrakoutBulletRenderer = BulletRendererScript.new()
	_assert(bullet_renderer.head_target_rect(Vector2(100, 200)) == Rect2(Vector2(100, 200), BulletRendererScript.HEAD_SOURCE_SIZE), "bullet renderer draws the native rocket head frame without compression")
	_assert(bullet_renderer.trail_target_rect(Vector2(100, 200)) == Rect2(Vector2(126, 200), BulletRendererScript.TRAIL_SOURCE_SIZE), "bullet renderer draws the native rocket trail frame without compression")
	bullet_renderer.free()

	var monster_renderer = MonsterRendererScript.new()
	_assert(monster_renderer.source_rect_for_monster(3, 0) == Rect2(Vector2(96, 0), Vector2(32, 32)), "monster renderer maps original type 3 frame")
	_assert(monster_renderer.source_rect_for_monster(9, 19) == Rect2(Vector2(288, 608), Vector2(32, 32)), "monster renderer maps original type 9 final stun-hazard frame")
	_assert(monster_renderer.source_rect_for_monster(10, 7) == Rect2(Vector2(320, 224), Vector2(32, 32)), "monster renderer maps original type 10 animation row")
	monster_renderer.free()

	var bee_renderer = BeeRendererScript.new()
	_assert(bee_renderer.source_rect_for_bee(0) == Rect2(Vector2(0, 0), Vector2(48, 40)), "bee renderer maps original first bee frame")
	_assert(bee_renderer.source_rect_for_bee(5) == Rect2(Vector2(0, 200), Vector2(48, 40)), "bee renderer maps original final bee frame")
	bee_renderer.free()
	_assert(SnakeRendererScript.source_rect_for_kind(0) == Rect2(Vector2(0, 0), Vector2(10, 10)), "snake renderer maps original kind 0")
	_assert(SnakeRendererScript.source_rect_for_kind(1) == Rect2(Vector2(0, 10), Vector2(10, 10)), "snake renderer maps original kind 1")
	_assert(SnakeRendererScript.source_rect_for_kind(4) == Rect2(Vector2(10, 0), Vector2(10, 10)), "snake renderer maps original kind 4")
	_assert(SnakeRendererScript.source_rect_for_kind(16) == Rect2(Vector2(40, 0), Vector2(10, 10)), "snake renderer maps original kind 16")
	_assert(SnakeRendererScript.source_rect_for_kind(19) == Rect2(Vector2(40, 30), Vector2(10, 10)), "snake renderer maps original kind 19")
	_assert(SnakeRendererScript.source_rect_for_kind(25) == Rect2(Vector2(40, 30), Vector2(10, 10)), "snake renderer clamps out-of-range kinds")

	var impact_renderer = ImpactEffectRendererScript.new()
	_assert(impact_renderer.source_rect_for_effect(GameSessionScript.IMPACT_EFFECT_KIND_MONSTER_SPAWN, 0) == Rect2(Vector2(0, 0), Vector2(32, 32)), "impact renderer maps original monster-spawn effect cell")
	_assert(impact_renderer.source_rect_for_effect(GameSessionScript.IMPACT_EFFECT_KIND_MONSTER_TIMEOUT, 10) == Rect2(Vector2(32, 320), Vector2(32, 32)), "impact renderer maps original monster-timeout final frame")
	_assert(impact_renderer.source_rect_for_effect(GameSessionScript.IMPACT_EFFECT_KIND_SNAKE_HIT, 4) == Rect2(Vector2(32, 128), Vector2(32, 32)), "impact renderer maps original Snake contact kind-1 effect column")
	_assert(impact_renderer.source_rect_for_effect(GameSessionScript.IMPACT_EFFECT_KIND_MONSTER_HIT, 3) == Rect2(Vector2(64, 96), Vector2(32, 32)), "impact renderer advances original monster-hit vertical frames")
	_assert(impact_renderer.source_rect_for_effect(GameSessionScript.IMPACT_EFFECT_KIND_CHAIN_EXPLOSION, 3) == Rect2(Vector2(64, 96), Vector2(32, 32)), "impact renderer reuses the original explosion cell for chain board VFX")
	_assert(impact_renderer.source_rect_for_effect(GameSessionScript.IMPACT_EFFECT_KIND_BRICK_CLEAR, 2) == Rect2(Vector2(96, 64), Vector2(20, 32)), "impact renderer maps original narrow brick-clear effect column")
	_assert(impact_renderer.source_rect_for_effect(GameSessionScript.IMPACT_EFFECT_KIND_HARD_BRICK_IMPACT, 4) == Rect2(Vector2(128, 128), Vector2(20, 32)), "impact renderer maps original narrow hard-brick impact effect column")
	_assert(impact_renderer.source_rect_for_effect(GameSessionScript.IMPACT_EFFECT_KIND_BONUS_BRICK_CLEAR, 0) == Rect2(Vector2(160, 0), Vector2(20, 32)), "impact renderer maps original narrow bonus-clear effect column")
	_assert(impact_renderer.target_rect_for_effect(Vector2(10, 20), GameSessionScript.IMPACT_EFFECT_KIND_BONUS_BRICK_CLEAR) == Rect2(Vector2(10, 20), Vector2(20, 32)), "impact renderer draws narrow effect columns at original width")
	impact_renderer.free()

	var score_popup_renderer = ScorePopupRendererScript.new()
	_assert(ScorePopupRendererScript.digit_source_rect(5, 3) == Rect2(Vector2(40, 36), Vector2(8, 12)), "score-popup renderer maps DigitsSmall digit columns and animation rows")
	_assert(ScorePopupRendererScript.digit_source_rect(12, 99) == Rect2(Vector2(72, 168), Vector2(8, 12)), "score-popup renderer clamps out-of-range DigitsSmall coordinates")
	_assert(ScorePopupRendererScript.digit_target_rect(Vector2(20, 30), 2) == Rect2(Vector2(36, 30), Vector2(8, 12)), "score-popup renderer advances target digits by original 8px cells")
	var score_popup_rects: Array[Dictionary] = score_popup_renderer.popup_digit_rects({
		"position": Vector2(20, 30),
		"value": 105,
		"frame": 2,
	})
	_assert(score_popup_rects.size() == 3, "score-popup renderer emits one draw region per decimal digit")
	if score_popup_rects.size() == 3:
		_assert(score_popup_rects[0]["source"] == Rect2(Vector2(8, 24), Vector2(8, 12)), "score-popup renderer maps first multi-digit source")
		_assert(score_popup_rects[1]["source"] == Rect2(Vector2(0, 24), Vector2(8, 12)), "score-popup renderer maps zero inside multi-digit values")
		_assert(score_popup_rects[2]["destination"] == Rect2(Vector2(36, 30), Vector2(8, 12)), "score-popup renderer places trailing digit at original offset")
	score_popup_renderer.free()


func _validate_project_presentation_settings() -> void:
	_assert(ProjectSettings.get_setting("display/window/size/viewport_width") == 640, "project keeps original viewport width")
	_assert(ProjectSettings.get_setting("display/window/size/viewport_height") == 480, "project keeps original viewport height")
	_assert(ProjectSettings.get_setting("display/window/stretch/mode") == "viewport", "project stretches the fixed original viewport")
	_assert(ProjectSettings.get_setting("display/window/stretch/aspect") == "keep", "project keeps the original 4:3 aspect ratio")


func _validate_project_input_map() -> void:
	var expected_actions: Array[String] = [
		GameScreenScript.ACTION_LAUNCH_BALL,
		GameScreenScript.ACTION_FIRE_PADDLE,
		GameScreenScript.ACTION_USE_BONUS,
		GameScreenScript.ACTION_TOGGLE_BONUS_STACK,
		GameScreenScript.ACTION_TOGGLE_BALL_TRACKS,
		GameScreenScript.ACTION_TOGGLE_FPS,
		GameScreenScript.ACTION_TOGGLE_MUSIC,
		GameScreenScript.ACTION_TOGGLE_SFX,
		GameScreenScript.ACTION_PAUSE,
		GameScreenScript.ACTION_TERMINATE_GAME,
		GameScreenScript.ACTION_CYCLE_BACKGROUND,
		GameScreenScript.ACTION_TOGGLE_BACKGROUND_MOTION,
		GameScreenScript.ACTION_TOGGLE_FULLSCREEN,
		GameScreenScript.ACTION_RELEASE_CURSOR,
		GameScreenScript.ACTION_DEBUG_CHEATS,
	]
	for action_name: String in expected_actions:
		_assert(InputMap.has_action(action_name), "project input action exists: %s" % action_name)

	_assert(_action_has_mouse_button(GameScreenScript.ACTION_LAUNCH_BALL, MOUSE_BUTTON_LEFT), "launch action binds left mouse button")
	_assert(_action_has_mouse_button(GameScreenScript.ACTION_FIRE_PADDLE, MOUSE_BUTTON_RIGHT), "shooting-paddle action binds right mouse button")
	_assert(_action_has_key(GameScreenScript.ACTION_USE_BONUS, KEY_SPACE), "use-bonus action binds Space")
	_assert(_action_has_key(GameScreenScript.ACTION_TOGGLE_BONUS_STACK, KEY_TAB), "bonus-stack action binds Tab")
	_assert(_action_has_key(GameScreenScript.ACTION_TOGGLE_BALL_TRACKS, KEY_T, true), "ball-tracks action binds Ctrl+T")
	_assert(_action_has_key(GameScreenScript.ACTION_TOGGLE_FPS, KEY_F5), "FPS action binds F5")
	_assert(_action_has_key(GameScreenScript.ACTION_TOGGLE_MUSIC, KEY_F7), "music toggle action binds F7")
	_assert(_action_has_key(GameScreenScript.ACTION_TOGGLE_SFX, KEY_F8), "SFX toggle action binds F8")
	_assert(_action_has_key(GameScreenScript.ACTION_PAUSE, KEY_P), "pause action binds P")
	_assert(_action_has_key(GameScreenScript.ACTION_TERMINATE_GAME, KEY_ESCAPE), "terminate-game action binds Escape")
	_assert(_action_has_key(GameScreenScript.ACTION_CYCLE_BACKGROUND, KEY_G), "background-cycle action binds G")
	_assert(_action_has_key(GameScreenScript.ACTION_TOGGLE_BACKGROUND_MOTION, KEY_G, false, true), "background motion action binds Shift+G")
	_assert(_action_has_key(GameScreenScript.ACTION_TOGGLE_FULLSCREEN, KEY_ENTER, false, false, true), "fullscreen action binds Alt+Enter")
	_assert(_action_has_key(GameScreenScript.ACTION_RELEASE_CURSOR, KEY_U, true), "release-cursor action binds Ctrl+U")
	_assert(_action_has_key(GameScreenScript.ACTION_DEBUG_CHEATS, KEY_D), "debug-cheats action binds D")


func _validate_legacy_high_score_file() -> void:
	var original_high_score_path := _project_file_path("extract-krakout-assets/krakout/Krakout.high")
	_assert(FileAccess.file_exists(original_high_score_path), "original Krakout.high fixture exists")
	var original_entries: Array = HighScoreFileScript.load_entries(original_high_score_path)
	_assert(original_entries.is_empty(), "original Krakout.high fixture decodes to the empty default table")

	var encoded_entries := HighScoreFileScript.encode_entries([
		{"name": "Middle", "score": 900, "level": 4, "episode": "Retro"},
		{"name": "Top", "score": 1200, "level": 7, "episode": "Default"},
		{"name": "TieOne", "score": 700, "level": 3, "episode": "Classic"},
		{"name": "TieTwo", "score": 700, "level": 5, "episode": "Classic"},
		{"name": "Zero", "score": 0, "level": 2, "episode": "Default"},
	])
	_assert(encoded_entries.size() == HighScoreFileScript.FILE_BYTES, "legacy high-score encoder writes exact original file size")
	_assert(int(encoded_entries[0]) == "T".to_ascii_buffer()[0], "legacy high-score encoder stores first sorted name at record offset 0")
	_assert(int(encoded_entries[100]) == ("D".to_ascii_buffer()[0] ^ 100), "legacy high-score encoder stores episode at original field offset")
	_assert(int(encoded_entries[200]) == (7 ^ 200), "legacy high-score encoder stores level at original field offset")
	_assert(int(encoded_entries[204]) == ((1200 & 0xff) ^ 204), "legacy high-score encoder stores score at original field offset")
	var decoded_entries: Array = HighScoreFileScript.decode_entries(encoded_entries)
	_assert(decoded_entries.size() == 4, "legacy high-score decoder skips zero-score rows")
	_assert(decoded_entries[0]["name"] == "Top", "legacy high-score decoder sorts table by score")
	_assert(decoded_entries[0]["score"] == 1200, "legacy high-score decoder preserves score")
	_assert(decoded_entries[0]["level"] == 7, "legacy high-score decoder preserves reached level")
	_assert(decoded_entries[0]["episode"] == "Default", "legacy high-score decoder preserves episode")
	_assert(decoded_entries[2]["name"] == "TieOne" and decoded_entries[3]["name"] == "TieTwo", "legacy high-score decoder keeps stable tied-score order")

	var overflow_entries: Array = []
	for index in range(12):
		overflow_entries.append({"name": "Player%d" % index, "score": 1000 + index, "level": index + 1, "episode": "Default"})
	var overflow_decoded: Array = HighScoreFileScript.decode_entries(HighScoreFileScript.encode_entries(overflow_entries))
	_assert(overflow_decoded.size() == HighScoreFileScript.ENTRY_COUNT, "legacy high-score codec trims to original ten-row table")
	_assert(overflow_decoded[0]["name"] == "Player11", "legacy high-score codec keeps the highest score after trimming")

	var invalid_path := _test_legacy_high_score_path("invalid")
	var invalid_file := FileAccess.open(invalid_path, FileAccess.WRITE)
	if invalid_file != null:
		invalid_file.store_buffer(PackedByteArray([1, 2, 3]))
	_assert(HighScoreFileScript.load_entries(invalid_path).is_empty(), "legacy high-score decoder rejects invalid-size files")


func _validate_profile_service() -> void:
	var save_path := _test_profile_path("profile_service")
	var legacy_path := _test_legacy_high_score_path("profile_service")
	var profile = ProfileScript.new()
	profile.set_save_path(save_path, false)
	profile.set_legacy_high_score_path(legacy_path)
	_assert(profile.best_score() == 0, "profile defaults high score to zero")
	_assert(profile.bonus_stack_visible(), "profile defaults bonus stack visible")
	_assert(profile.ball_tracks_visible(), "profile defaults ball tracks visible")
	_assert(not profile.fps_visible(), "profile defaults FPS hidden")
	_assert(profile.background_movable(), "profile defaults background movable from original config")
	_assert(profile.background_type() == 2, "profile defaults to original BgType")
	_assert(not profile.fullscreen_enabled(), "profile defaults fullscreen disabled")
	_assert(profile.music_enabled(), "profile defaults music enabled")
	_assert(profile.sfx_enabled(), "profile defaults SFX enabled")
	_assert(profile.music_volume() == 80, "profile defaults music volume")
	_assert(profile.sfx_volume() == 85, "profile defaults SFX volume")
	_assert(profile.record_score(885), "profile records a new high score")
	_assert(profile.best_score() == 885, "profile exposes recorded high score")
	_assert(FileAccess.file_exists(legacy_path), "profile mirrors recorded scores to legacy Krakout.high")
	var mirrored_entries: Array = HighScoreFileScript.load_entries(legacy_path)
	_assert(mirrored_entries.size() == 1, "profile legacy mirror contains materialized best score")
	_assert(mirrored_entries[0]["name"] == "Anonymous", "profile legacy mirror uses anonymous fallback")
	_assert(mirrored_entries[0]["score"] == 885, "profile legacy mirror preserves score")
	var legacy_entries: Array = profile.high_score_entries()
	_assert(legacy_entries.size() == 1, "profile exposes legacy best score as a table entry")
	_assert(legacy_entries[0]["name"] == "Anonymous", "profile uses original anonymous fallback for legacy scores")
	_assert(legacy_entries[0]["score"] == 885, "profile legacy table entry mirrors best score")
	_assert(profile.would_enter_high_score(120), "profile accepts positive scores while the high-score table has room")
	_assert(not profile.would_enter_high_score(0), "profile rejects zero scores for high-score entry")
	_assert(not profile.record_score(120), "profile ignores lower scores")
	_assert(profile.best_score() == 885, "profile preserves higher score")
	_assert(profile.set_bonus_stack_visible(false), "profile persists hidden bonus stack setting")
	_assert(profile.set_ball_tracks_visible(false), "profile persists hidden ball tracks setting")
	_assert(profile.set_fps_visible(true), "profile persists visible FPS setting")
	_assert(profile.set_background_movable(false), "profile persists static background setting")
	_assert(profile.set_background_type(7), "profile persists the final original background type")
	_assert(profile.set_fullscreen_enabled(true), "profile persists fullscreen enabled setting")
	_assert(profile.set_music_enabled(false), "profile persists disabled music setting")
	_assert(profile.set_sfx_enabled(false), "profile persists disabled SFX setting")
	_assert(profile.set_music_volume(35), "profile persists music volume setting")
	_assert(profile.set_sfx_volume(120), "profile clamps and persists SFX volume setting")

	var reloaded_profile = ProfileScript.new()
	reloaded_profile.set_save_path(save_path, false)
	reloaded_profile.set_legacy_high_score_path(legacy_path)
	reloaded_profile.load_profile()
	_assert(reloaded_profile.best_score() == 885, "profile reloads persisted high score")
	_assert(not reloaded_profile.bonus_stack_visible(), "profile reloads bonus stack setting")
	_assert(not reloaded_profile.ball_tracks_visible(), "profile reloads ball tracks setting")
	_assert(reloaded_profile.fps_visible(), "profile reloads FPS setting")
	_assert(not reloaded_profile.background_movable(), "profile reloads background movable setting")
	_assert(reloaded_profile.background_type() == 7, "profile reloads background type setting")
	_assert(reloaded_profile.fullscreen_enabled(), "profile reloads fullscreen setting")
	_assert(not reloaded_profile.music_enabled(), "profile reloads music enabled setting")
	_assert(not reloaded_profile.sfx_enabled(), "profile reloads SFX enabled setting")
	_assert(reloaded_profile.music_volume() == 35, "profile reloads music volume setting")
	_assert(reloaded_profile.sfx_volume() == 100, "profile reloads clamped SFX volume setting")
	_assert(reloaded_profile.set_best_score(1200), "profile can replace high score with a higher value")

	var final_profile = ProfileScript.new()
	final_profile.set_save_path(save_path, false)
	final_profile.set_legacy_high_score_path(legacy_path)
	final_profile.load_profile()
	_assert(final_profile.best_score() == 1200, "profile persists updated high score")
	_assert(final_profile.background_type() == 7, "profile keeps presentation settings when high score changes")
	_assert(final_profile.fullscreen_enabled(), "profile keeps fullscreen setting when high score changes")
	_assert(profile.set_background_type(42), "profile normalizes out-of-range background types")
	_assert(profile.background_type() == 0, "profile resets out-of-range background types to the original first entry")
	var normalized_profile = ProfileScript.new()
	normalized_profile.set_save_path(save_path, false)
	normalized_profile.set_legacy_high_score_path(legacy_path)
	normalized_profile.load_profile()
	_assert(normalized_profile.background_type() == 0, "profile reload keeps normalized out-of-range background type")
	_assert(final_profile.music_volume() == 35, "profile keeps audio settings when high score changes")

	var table_path := _test_profile_path("profile_table")
	var table_legacy_path := _test_legacy_high_score_path("profile_table")
	var table_profile = ProfileScript.new()
	table_profile.set_save_path(table_path, false)
	table_profile.set_legacy_high_score_path(table_legacy_path)
	_assert(table_profile.submit_high_score(" Ada  ", 900, 4, "Retro"), "profile accepts named high-score entry")
	_assert(table_profile.submit_high_score("", 800, 2, "Default"), "profile accepts empty high-score name")
	_assert(table_profile.submit_high_score("TieOne", 700, 3, "Classic"), "profile accepts first tied score")
	_assert(table_profile.submit_high_score("TieTwo", 700, 5, "Classic"), "profile accepts second tied score")
	var table_entries: Array = table_profile.high_score_entries()
	_assert(table_entries.size() == 4, "profile exposes submitted score entries")
	_assert(table_entries[0]["name"] == "Ada", "profile trims submitted player names")
	_assert(table_entries[0]["score"] == 900, "profile sorts high-score table by score")
	_assert(table_entries[1]["name"] == "Anonymous", "profile defaults blank submitted names")
	_assert(table_entries[2]["name"] == "TieOne" and table_entries[3]["name"] == "TieTwo", "profile keeps stable ordering for tied scores")
	for index in range(12):
		table_profile.submit_high_score("Player%d" % index, 1000 + index, index + 1, "Default")
	table_entries = table_profile.high_score_entries()
	_assert(table_entries.size() == ProfileScript.HIGH_SCORE_TABLE_LIMIT, "profile trims high-score table to original display size")
	_assert(table_entries[0]["score"] == 1011, "profile keeps highest score after trimming")
	_assert(not table_profile.would_enter_high_score(1), "profile rejects scores below a full table")
	_assert(HighScoreFileScript.load_entries(table_legacy_path).size() == ProfileScript.HIGH_SCORE_TABLE_LIMIT, "profile mirrors submitted table to legacy Krakout.high")
	var reloaded_table_profile = ProfileScript.new()
	reloaded_table_profile.set_save_path(table_path, false)
	reloaded_table_profile.set_legacy_high_score_path(table_legacy_path)
	reloaded_table_profile.load_profile()
	_assert(reloaded_table_profile.high_score_entries().size() == ProfileScript.HIGH_SCORE_TABLE_LIMIT, "profile reloads persisted high-score table")
	_assert(reloaded_table_profile.best_score() == 1011, "profile best score follows table leader")

	var auto_import_path := _test_profile_path("legacy_auto_import")
	var auto_import_legacy_path := _test_legacy_high_score_path("legacy_auto_import")
	_assert(HighScoreFileScript.save_entries(auto_import_legacy_path, [
		{"name": "LegacyTop", "score": 3333, "level": 9, "episode": "Classic"},
	]), "test can write legacy high-score file")
	var auto_import_profile = ProfileScript.new()
	auto_import_profile.set_save_path(auto_import_path, false)
	auto_import_profile.set_legacy_high_score_path(auto_import_legacy_path)
	_assert(auto_import_profile.load_profile(), "profile loads when only legacy high-score file exists")
	var auto_import_entries: Array = auto_import_profile.high_score_entries()
	_assert(auto_import_entries.size() == 1, "profile imports legacy high-score file when native table is empty")
	_assert(auto_import_entries[0]["name"] == "LegacyTop", "profile preserves imported legacy name")
	_assert(auto_import_entries[0]["score"] == 3333, "profile preserves imported legacy score")

	var native_wins_path := _test_profile_path("native_wins")
	var native_wins_legacy_path := _test_legacy_high_score_path("native_wins")
	var native_wins_profile = ProfileScript.new()
	native_wins_profile.set_save_path(native_wins_path, false)
	native_wins_profile.set_legacy_high_score_path(native_wins_legacy_path)
	_assert(native_wins_profile.submit_high_score("Native", 500, 2, "Default"), "profile writes native table for legacy precedence test")
	_assert(HighScoreFileScript.save_entries(native_wins_legacy_path, [
		{"name": "Legacy", "score": 9999, "level": 10, "episode": "Retro"},
	]), "test can overwrite legacy high-score file")
	var native_wins_reloaded = ProfileScript.new()
	native_wins_reloaded.set_save_path(native_wins_path, false)
	native_wins_reloaded.set_legacy_high_score_path(native_wins_legacy_path)
	native_wins_reloaded.load_profile()
	var native_wins_entries: Array = native_wins_reloaded.high_score_entries()
	_assert(native_wins_entries[0]["name"] == "Native", "native profile table wins over legacy Krakout.high when both exist")

	var explicit_import_profile = ProfileScript.new()
	explicit_import_profile.set_save_path(_test_profile_path("explicit_import"), false)
	explicit_import_profile.set_legacy_high_score_path(_test_legacy_high_score_path("explicit_import"))
	_assert(explicit_import_profile.import_legacy_high_scores(auto_import_legacy_path, true), "profile explicit legacy import succeeds")
	_assert(explicit_import_profile.high_score_entries()[0]["name"] == "LegacyTop", "profile explicit legacy import updates table")
	var explicit_export_path := _test_legacy_high_score_path("explicit_export")
	_assert(explicit_import_profile.export_legacy_high_scores(explicit_export_path), "profile explicit legacy export succeeds")
	_assert(HighScoreFileScript.load_entries(explicit_export_path)[0]["score"] == 3333, "profile explicit legacy export round-trips score")

	profile.free()
	reloaded_profile.free()
	final_profile.free()
	normalized_profile.free()
	table_profile.free()
	reloaded_table_profile.free()
	auto_import_profile.free()
	native_wins_profile.free()
	native_wins_reloaded.free()
	explicit_import_profile.free()


func _validate_audio_cue_catalog() -> void:
	_assert(AudioCueCatalogScript.has_music_context(AudioCueCatalogScript.CONTEXT_MAIN_MENU), "audio cue catalog exposes main-menu music context")
	_assert(AudioCueCatalogScript.has_music_context(AudioCueCatalogScript.CONTEXT_RULES), "audio cue catalog exposes rules music context")
	_assert(AudioCueCatalogScript.has_music_context(AudioCueCatalogScript.CONTEXT_HIGH_SCORE), "audio cue catalog exposes high-score music context")
	_assert(AudioCueCatalogScript.has_music_context(AudioCueCatalogScript.CONTEXT_OPTIONS), "audio cue catalog exposes options music context")
	_assert(AudioCueCatalogScript.has_music_context(AudioCueCatalogScript.CONTEXT_CREDITS), "audio cue catalog exposes credits music context")
	_assert(AudioCueCatalogScript.has_music_context(AudioCueCatalogScript.CONTEXT_EPISODE_SELECT), "audio cue catalog exposes episode-select music context")
	_assert(AudioCueCatalogScript.has_music_context(AudioCueCatalogScript.CONTEXT_GAMEPLAY), "audio cue catalog exposes gameplay music context")
	_assert(AudioCueCatalogScript.has_music_context(AudioCueCatalogScript.CONTEXT_NAME_ENTRY), "audio cue catalog exposes name-entry music context")
	_assert(AudioCueCatalogScript.music_name_for_context(AudioCueCatalogScript.CONTEXT_MAIN_MENU) == "Abnormal", "audio cue catalog maps main menu to original-backed Abnormal module")
	_assert(AudioCueCatalogScript.music_name_for_context(AudioCueCatalogScript.CONTEXT_RULES) == "Abnormal", "audio cue catalog keeps rules on original main-menu module")
	_assert(AudioCueCatalogScript.music_name_for_context(AudioCueCatalogScript.CONTEXT_HIGH_SCORE) == "theme2", "audio cue catalog maps high score to original-backed theme2")
	_assert(AudioCueCatalogScript.music_name_for_context(AudioCueCatalogScript.CONTEXT_OPTIONS) == "Abnormal", "audio cue catalog keeps options on original main-menu module")
	_assert(AudioCueCatalogScript.music_name_for_context(AudioCueCatalogScript.CONTEXT_CREDITS) == "theme5", "audio cue catalog maps credits to original-backed theme5")
	_assert(AudioCueCatalogScript.music_name_for_context(AudioCueCatalogScript.CONTEXT_EPISODE_SELECT) == "theme1", "audio cue catalog maps episode select to original-backed theme1")
	_assert(AudioCueCatalogScript.music_name_for_context(AudioCueCatalogScript.CONTEXT_GAMEPLAY) == "theme4", "audio cue catalog maps gameplay to original-backed theme4")
	_assert(AudioCueCatalogScript.music_name_for_context(AudioCueCatalogScript.CONTEXT_NAME_ENTRY) == "theme3", "audio cue catalog maps name entry to original-backed theme3")
	_assert(AudioCueCatalogScript.music_name_for_context("missing_context") == "", "audio cue catalog rejects unknown contexts")
	var contexts: Array[String] = AudioCueCatalogScript.known_contexts()
	_assert(contexts == ["credits", "episode_select", "gameplay", "high_score", "main_menu", "name_entry", "options", "rules"], "audio cue catalog exposes sorted known contexts")
	_assert(AudioCueCatalogScript.has_sfx_event(GameSessionScript.SFX_EVENT_BRICK_CLEAR), "audio cue catalog recognizes brick-clear gameplay SFX event")
	_assert(AudioCueCatalogScript.has_sfx_event(GameSessionScript.SFX_EVENT_PROJECTILE_FIRE), "audio cue catalog recognizes projectile-fire gameplay SFX event")
	_assert(AudioCueCatalogScript.has_sfx_event(GameSessionScript.SFX_EVENT_BEE_STOP), "audio cue catalog recognizes bee-stop gameplay SFX event")
	_assert(AudioCueCatalogScript.has_sfx_event(AudioCueCatalogScript.SFX_EVENT_FRONTEND_SELECT), "audio cue catalog recognizes generic front-end selection SFX event")
	_assert(AudioCueCatalogScript.has_sfx_event(AudioCueCatalogScript.SFX_EVENT_FRONTEND_ACTIVATE), "audio cue catalog recognizes generic front-end activation SFX event")
	_assert(AudioCueCatalogScript.has_sfx_event(AudioCueCatalogScript.SFX_EVENT_MAIN_MENU_SELECT), "audio cue catalog recognizes main-menu selection SFX event")
	_assert(AudioCueCatalogScript.has_sfx_event(AudioCueCatalogScript.SFX_EVENT_EPISODE_ACTIVATE), "audio cue catalog recognizes episode activation SFX event")
	_assert(not AudioCueCatalogScript.has_sfx_event("missing_sfx_event"), "audio cue catalog rejects unknown SFX events")

	var expected_sfx_names := {
		AudioCueCatalogScript.SFX_EVENT_FRONTEND_SELECT: "eff02",
		AudioCueCatalogScript.SFX_EVENT_FRONTEND_ACTIVATE: "eff01",
		AudioCueCatalogScript.SFX_EVENT_MAIN_MENU_SELECT: "eff02",
		AudioCueCatalogScript.SFX_EVENT_MAIN_MENU_ACTIVATE: "eff01",
		AudioCueCatalogScript.SFX_EVENT_EPISODE_SELECT: "eff04",
		AudioCueCatalogScript.SFX_EVENT_EPISODE_ACTIVATE: "eff03",
		GameSessionScript.SFX_EVENT_RACKET_BOUNCE: "eff07",
		GameSessionScript.SFX_EVENT_BRICK_CLEAR: "eff23",
		GameSessionScript.SFX_EVENT_HARD_BRICK_HIT: "eff22",
		GameSessionScript.SFX_EVENT_CHAIN_EXPLOSION: "eff10",
		GameSessionScript.SFX_EVENT_BONUS_SPAWN: "eff11",
		GameSessionScript.SFX_EVENT_BONUS_EXPIRE: "eff12",
		GameSessionScript.SFX_EVENT_BONUS_COLLECT: "eff15",
		GameSessionScript.SFX_EVENT_BONUS_ADD_BALL_APPLY: "eff17",
		GameSessionScript.SFX_EVENT_BONUS_DESTROY_BALL_APPLY: "eff24",
		GameSessionScript.SFX_EVENT_BONUS_JUMP_LEVEL_APPLY: "eff19",
		GameSessionScript.SFX_EVENT_PROJECTILE_FIRE: "eff08",
		GameSessionScript.SFX_EVENT_MONSTER_SPAWN: "eff13",
		GameSessionScript.SFX_EVENT_MONSTER_EXPIRE: "eff14",
		GameSessionScript.SFX_EVENT_MONSTER_HIT: "eff09",
		GameSessionScript.SFX_EVENT_BEE_SPAWN: "EffBee",
		GameSessionScript.SFX_EVENT_LIFE_LOST: "eff16",
		GameSessionScript.SFX_EVENT_LEVEL_READY: "eff05",
		GameSessionScript.SFX_EVENT_LEVEL_COMPLETE: "eff19",
		GameSessionScript.SFX_EVENT_GAME_OVER: "eff18",
	}
	for event_name: String in expected_sfx_names.keys():
		_assert(
			AudioCueCatalogScript.sfx_name_for_event(event_name) == expected_sfx_names[event_name],
			"audio cue catalog maps %s to IDA-backed %s" % [event_name, expected_sfx_names[event_name]]
		)
	var expected_silent_events := [
		GameSessionScript.SFX_EVENT_BACK_WALL_BOUNCE,
		GameSessionScript.SFX_EVENT_BALL_LAUNCH,
		GameSessionScript.SFX_EVENT_BONUS_APPLY,
		GameSessionScript.SFX_EVENT_PROJECTILE_HIT,
	]
	var expected_silent_reason_fragments := {
		GameSessionScript.SFX_EVENT_BACK_WALL_BOUNCE: "sub_4012D0",
		GameSessionScript.SFX_EVENT_BALL_LAUNCH: "sub_40DA00/sub_40E580",
		GameSessionScript.SFX_EVENT_BONUS_APPLY: "sub_4110E0",
		GameSessionScript.SFX_EVENT_PROJECTILE_HIT: "sub_403630",
	}
	_assert(AudioCueCatalogScript.intentionally_silent_sfx_events() == expected_silent_events, "audio cue catalog records the audited silent gameplay SFX events")
	for silent_event_name: String in expected_silent_events:
		_assert(AudioCueCatalogScript.has_sfx_event(silent_event_name), "audio cue catalog keeps silent event %s in the semantic event list" % silent_event_name)
		_assert(AudioCueCatalogScript.sfx_name_for_event(silent_event_name) == "", "audio cue catalog leaves audited silent event %s unmapped" % silent_event_name)
		_assert(AudioCueCatalogScript.is_sfx_event_intentionally_silent(silent_event_name), "audio cue catalog marks %s as intentionally silent" % silent_event_name)
		var silent_reason := AudioCueCatalogScript.silent_sfx_event_reason(silent_event_name)
		_assert(not silent_reason.is_empty(), "audio cue catalog explains why %s is silent" % silent_event_name)
		_assert(
			silent_reason.contains(String(expected_silent_reason_fragments[silent_event_name])),
			"audio cue catalog records IDA evidence for silent event %s" % silent_event_name
		)
	_assert(not AudioCueCatalogScript.is_sfx_event_intentionally_silent(GameSessionScript.SFX_EVENT_BRICK_CLEAR), "audio cue catalog does not mark proven mapped cues as silent")
	_assert(AudioCueCatalogScript.sfx_name_for_event(GameSessionScript.SFX_EVENT_BEE_STOP) == "", "audio cue catalog does not play bee-stop as a new SFX")
	_assert(AudioCueCatalogScript.sfx_stop_name_for_event(GameSessionScript.SFX_EVENT_BEE_STOP) == "EffBee", "audio cue catalog maps bee-stop to the active EffBee playback")
	_assert(AudioCueCatalogScript.is_sfx_stop_event(GameSessionScript.SFX_EVENT_BEE_STOP), "audio cue catalog marks bee-stop as a stop event")
	_assert(AudioCueCatalogScript.sfx_name_for_event(GameSessionScript.SFX_EVENT_LEVEL_READY) != AudioCueCatalogScript.sfx_name_for_event(GameSessionScript.SFX_EVENT_LEVEL_COMPLETE), "audio cue catalog keeps start and ending cues distinct")
	_assert(AudioCueCatalogScript.sfx_name_for_event("missing_sfx_event") == "", "audio cue catalog leaves unknown SFX events silent")
	var sfx_events: Array[String] = AudioCueCatalogScript.known_sfx_events()
	_assert(sfx_events.has(GameSessionScript.SFX_EVENT_BONUS_EXPIRE), "audio cue catalog exposes bonus-expire event in known event list")
	_assert(sfx_events.has(GameSessionScript.SFX_EVENT_BONUS_APPLY), "audio cue catalog exposes bonus-apply event in known event list")
	_assert(sfx_events.has(GameSessionScript.SFX_EVENT_BONUS_ADD_BALL_APPLY), "audio cue catalog exposes add-ball apply event in known event list")
	_assert(sfx_events.has(GameSessionScript.SFX_EVENT_BONUS_DESTROY_BALL_APPLY), "audio cue catalog exposes destroy-ball apply event in known event list")
	_assert(sfx_events.has(GameSessionScript.SFX_EVENT_BONUS_JUMP_LEVEL_APPLY), "audio cue catalog exposes jump-level apply event in known event list")
	_assert(sfx_events.has(GameSessionScript.SFX_EVENT_HARD_BRICK_HIT), "audio cue catalog exposes hard-brick-hit event in known event list")
	_assert(sfx_events.has(GameSessionScript.SFX_EVENT_BEE_SPAWN), "audio cue catalog exposes bee-spawn event in known event list")
	_assert(sfx_events.has(GameSessionScript.SFX_EVENT_BEE_STOP), "audio cue catalog exposes bee-stop event in known event list")
	_assert(sfx_events.has(GameSessionScript.SFX_EVENT_LEVEL_READY), "audio cue catalog exposes level-ready event in known event list")
	_assert(sfx_events.has(GameSessionScript.SFX_EVENT_MONSTER_EXPIRE), "audio cue catalog exposes monster-expire event in known event list")
	_assert(sfx_events.has(GameSessionScript.SFX_EVENT_GAME_OVER), "audio cue catalog exposes game-over event in known event list")
	_assert(sfx_events.has(AudioCueCatalogScript.SFX_EVENT_FRONTEND_SELECT), "audio cue catalog exposes generic front-end selection event in known event list")
	_assert(sfx_events.has(AudioCueCatalogScript.SFX_EVENT_FRONTEND_ACTIVATE), "audio cue catalog exposes generic front-end activation event in known event list")
	_assert(sfx_events.has(AudioCueCatalogScript.SFX_EVENT_MAIN_MENU_SELECT), "audio cue catalog exposes main-menu selection event in known event list")
	_assert(sfx_events.has(AudioCueCatalogScript.SFX_EVENT_EPISODE_ACTIVATE), "audio cue catalog exposes episode activation event in known event list")
	var mapped_sfx_names: Array[String] = []
	for event_name: String in sfx_events:
		var mapped_sfx_name := AudioCueCatalogScript.sfx_name_for_event(event_name)
		if not mapped_sfx_name.is_empty() and not mapped_sfx_names.has(mapped_sfx_name):
			mapped_sfx_names.append(mapped_sfx_name)
	var unused_extracted_sfx_names: Array[String] = AudioCueCatalogScript.unused_extracted_sfx_names()
	_assert(unused_extracted_sfx_names == ["eff06", "eff20", "eff21"], "audio cue catalog records extracted SFX absent from executable sample-load strings")
	for sfx_name: String in unused_extracted_sfx_names:
		_assert(not mapped_sfx_names.has(sfx_name), "audio cue catalog does not map unused extracted SFX %s to gameplay" % sfx_name)


func _validate_audio_service() -> void:
	_assert(_audio != null, "audio autoload exists")
	if _audio == null:
		return

	await process_frame
	_assert(_audio.has_method("play_music"), "audio service exposes music playback")
	_assert(_audio.has_method("play_music_context"), "audio service exposes music-context playback")
	_assert(_audio.has_method("music_name_for_context"), "audio service exposes music context lookup")
	_assert(_audio.has_method("play_sfx"), "audio service exposes SFX playback")
	_assert(_audio.has_method("play_sfx_event"), "audio service exposes semantic SFX event playback")
	_assert(_audio.has_method("play_sfx_event_at_pan100"), "audio service exposes positioned semantic SFX playback")
	_assert(_audio.has_method("play_sfx_event_payload"), "audio service exposes SFX event payload playback")
	_assert(_audio.has_method("last_sfx_pan100_for_name"), "audio service exposes testable SFX pan metadata")
	_assert(_audio.has_method("stop_sfx_event"), "audio service exposes semantic SFX stop events")
	_assert(_audio.has_method("is_sfx_stop_event"), "audio service exposes SFX stop event lookup")
	_assert(_audio.has_method("is_sfx_playing"), "audio service exposes active SFX lookup")
	_assert(_audio.has_method("sfx_name_for_event"), "audio service exposes SFX event lookup")
	_assert(_audio.has_method("has_sfx_event"), "audio service exposes known SFX event lookup")
	_assert(bool(_audio.call("music_stream_exists", "theme1")), "audio service resolves extracted music track")
	_assert(bool(_audio.call("music_stream_exists", "theme2")), "audio service resolves high-score music track")
	_assert(bool(_audio.call("music_stream_exists", "theme5")), "audio service resolves credits music track")
	_assert(bool(_audio.call("music_stream_exists", "theme3")), "audio service resolves name-entry music track")
	_assert(bool(_audio.call("music_stream_exists", "theme4")), "audio service resolves gameplay music track")
	_assert(bool(_audio.call("music_stream_exists", "Abnormal")), "audio service resolves abnormal music track")
	_assert(bool(_audio.call("sfx_stream_exists", "eff01")), "audio service resolves extracted SFX")
	_assert(bool(_audio.call("sfx_stream_exists", "eff02")), "audio service resolves main-menu selection SFX")
	_assert(bool(_audio.call("sfx_stream_exists", "eff03")), "audio service resolves episode activation SFX")
	_assert(bool(_audio.call("sfx_stream_exists", "eff04")), "audio service resolves episode selection SFX")
	_assert(bool(_audio.call("sfx_stream_exists", "EffBee")), "audio service resolves extracted bee SFX")
	_assert(not bool(_audio.call("music_stream_exists", "missing_track")), "audio service rejects unknown music track")
	_assert(not bool(_audio.call("sfx_stream_exists", "missing_sfx")), "audio service rejects unknown SFX")
	_assert(String(_audio.call("music_name_for_context", AudioCueCatalogScript.CONTEXT_MAIN_MENU)) == "Abnormal", "audio service maps main-menu music context")
	_assert(String(_audio.call("music_name_for_context", AudioCueCatalogScript.CONTEXT_HIGH_SCORE)) == "theme2", "audio service maps high-score music context")
	_assert(String(_audio.call("music_name_for_context", AudioCueCatalogScript.CONTEXT_CREDITS)) == "theme5", "audio service maps credits music context")
	_assert(String(_audio.call("music_name_for_context", AudioCueCatalogScript.CONTEXT_EPISODE_SELECT)) == "theme1", "audio service maps episode-select music context")
	_assert(String(_audio.call("music_name_for_context", AudioCueCatalogScript.CONTEXT_GAMEPLAY)) == "theme4", "audio service maps gameplay music context")
	_assert(String(_audio.call("music_name_for_context", AudioCueCatalogScript.CONTEXT_NAME_ENTRY)) == "theme3", "audio service maps name-entry music context")
	_assert(String(_audio.call("music_name_for_context", "missing_context")) == "", "audio service rejects unknown music context")
	_assert(bool(_audio.call("has_sfx_event", GameSessionScript.SFX_EVENT_BRICK_CLEAR)), "audio service recognizes brick-clear SFX event")
	_assert(bool(_audio.call("has_sfx_event", GameSessionScript.SFX_EVENT_PROJECTILE_FIRE)), "audio service recognizes projectile-fire SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_BRICK_CLEAR)) == "eff23", "audio service maps brick-clear SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_CHAIN_EXPLOSION)) == "eff10", "audio service maps chain-explosion SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_BALL_LAUNCH)) == "", "audio service leaves initial ball launch silent")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_RACKET_BOUNCE)) == "eff07", "audio service maps racket-bounce SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_BONUS_SPAWN)) == "eff11", "audio service maps bonus-spawn SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_BONUS_EXPIRE)) == "eff12", "audio service maps bonus-expire SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_BONUS_COLLECT)) == "eff15", "audio service maps bonus-collect SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_BONUS_ADD_BALL_APPLY)) == "eff17", "audio service maps add-ball apply SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_BONUS_DESTROY_BALL_APPLY)) == "eff24", "audio service maps destroy-ball apply SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_BONUS_JUMP_LEVEL_APPLY)) == "eff19", "audio service maps jump-level apply SFX event")
	_assert(String(_audio.call("sfx_name_for_event", AudioCueCatalogScript.SFX_EVENT_FRONTEND_SELECT)) == "eff02", "audio service maps generic front-end selection SFX event")
	_assert(String(_audio.call("sfx_name_for_event", AudioCueCatalogScript.SFX_EVENT_FRONTEND_ACTIVATE)) == "eff01", "audio service maps generic front-end activation SFX event")
	_assert(String(_audio.call("sfx_name_for_event", AudioCueCatalogScript.SFX_EVENT_MAIN_MENU_SELECT)) == "eff02", "audio service maps main-menu selection SFX event")
	_assert(String(_audio.call("sfx_name_for_event", AudioCueCatalogScript.SFX_EVENT_MAIN_MENU_ACTIVATE)) == "eff01", "audio service maps main-menu activation SFX event")
	_assert(String(_audio.call("sfx_name_for_event", AudioCueCatalogScript.SFX_EVENT_EPISODE_SELECT)) == "eff04", "audio service maps episode-selection SFX event")
	_assert(String(_audio.call("sfx_name_for_event", AudioCueCatalogScript.SFX_EVENT_EPISODE_ACTIVATE)) == "eff03", "audio service maps episode-activation SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_HARD_BRICK_HIT)) == "eff22", "audio service maps hard-brick-hit SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_PROJECTILE_FIRE)) == "eff08", "audio service maps projectile-fire SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_MONSTER_SPAWN)) == "eff13", "audio service maps monster-spawn SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_MONSTER_EXPIRE)) == "eff14", "audio service maps monster-expire SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_MONSTER_HIT)) == "eff09", "audio service maps monster-hit SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_BEE_SPAWN)) == "EffBee", "audio service maps bee-spawn SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_LIFE_LOST)) == "eff16", "audio service maps life-lost SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_LEVEL_READY)) == "eff05", "audio service maps level-ready SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_LEVEL_COMPLETE)) == "eff19", "audio service maps level-complete SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_GAME_OVER)) == "eff18", "audio service maps game-over SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_BONUS_APPLY)) == "", "audio service leaves generic bonus-apply unmapped")
	_assert(String(_audio.call("sfx_stop_name_for_event", GameSessionScript.SFX_EVENT_BEE_STOP)) == "EffBee", "audio service maps bee-stop to EffBee")
	_assert(bool(_audio.call("is_sfx_stop_event", GameSessionScript.SFX_EVENT_BEE_STOP)), "audio service recognizes bee-stop as a stop event")

	_audio.call("set_music_enabled", true)
	_audio.call("set_music_volume", 50)
	_assert(int(_audio.call("music_volume")) == 50, "audio service clamps and exposes music volume")
	_audio.call("set_music_enabled", false)
	_assert(bool(_audio.call("play_music", "theme1", true)), "audio service accepts known disabled music track")
	_assert(String(_audio.call("current_music_name")) == "theme1", "audio service records current music track")
	_assert(String(_audio.call("current_music_context")) == "", "direct music playback clears current music context")
	_assert(bool(_audio.call("play_music_context", AudioCueCatalogScript.CONTEXT_GAMEPLAY, true)), "audio service accepts known disabled music context")
	_assert(String(_audio.call("current_music_context")) == AudioCueCatalogScript.CONTEXT_GAMEPLAY, "audio service records current music context")
	_assert(String(_audio.call("current_music_name")) == "theme4", "audio service records context music track")
	_assert(not bool(_audio.call("is_music_playing")), "audio service does not play music when disabled")

	_audio.call("set_sfx_enabled", true)
	_audio.call("set_sfx_volume", -20)
	_assert(int(_audio.call("sfx_volume")) == 0, "audio service clamps minimum SFX volume")
	_assert(not bool(_audio.call("play_sfx", "eff01")), "audio service suppresses muted SFX")
	_audio.call("set_sfx_volume", 65)
	_assert(bool(_audio.call("play_sfx_event_at_pan100", GameSessionScript.SFX_EVENT_BRICK_CLEAR, -50.0)), "audio service can play positioned semantic gameplay SFX")
	_assert(is_equal_approx(float(_audio.call("last_sfx_pan100_for_name", "eff23")), -50.0), "audio service stores the last pan for positioned gameplay SFX")
	_assert(bool(_audio.call("play_sfx_event_payload", {"event": GameSessionScript.SFX_EVENT_PROJECTILE_FIRE, "pan100": 75.0})), "audio service can play dictionary SFX payloads")
	_assert(is_equal_approx(float(_audio.call("last_sfx_pan100_for_name", "eff08")), 75.0), "audio service applies SFX payload pan")
	_assert(bool(_audio.call("play_sfx", "EffBee")), "audio service can start active bee SFX")
	_assert(bool(_audio.call("is_sfx_playing", "EffBee")), "audio service tracks active bee SFX")
	_assert(bool(_audio.call("stop_sfx_event", GameSessionScript.SFX_EVENT_BEE_STOP)), "audio service stops active bee SFX by semantic event")
	_assert(not bool(_audio.call("is_sfx_playing", "EffBee")), "audio service stops EffBee playback after bee-stop")
	_audio.call("set_sfx_enabled", false)


func _validate_bitmap_text_metrics() -> void:
	var font_texture := load(_assets.texture_path("Font")) as Texture2D
	_assert(font_texture != null, "bitmap font texture loads")
	var font_text = BitmapTextScript.new()
	font_text.configure(
		font_texture,
		BitmapTextScript.FONT_CHARSET,
		BitmapTextScript.FONT_CELL_SIZE,
		BitmapTextScript.FONT_ADVANCES,
		BitmapTextScript.FONT_SPACE_ADVANCE
	)
	_assert(font_text.measure_text("Your Score") == 173, "bitmap font measures original Your Score width")
	_assert(font_text.measure_text("Balls Left") == 153, "bitmap font measures original Balls Left width")
	_assert(font_text.measure_text("Level") == 84, "bitmap font measures original Level width")
	_assert(font_text.measure_text("High Score") == 164, "bitmap font measures original High Score width")
	_assert(font_text.measure_text("0") == 18, "bitmap font measures original header zero width")
	_assert(font_text.measure_text("885") == 54, "bitmap font measures original header high score width")
	_assert(font_text.bounds_for_text("Level", Vector2(320, 0), HORIZONTAL_ALIGNMENT_CENTER) == Rect2(Vector2(278, 0), Vector2(84, 24)), "bitmap font supports centered bounds")

	var digit_texture := load(_assets.texture_path("Digits")) as Texture2D
	_assert(digit_texture != null, "bitmap digit texture loads")
	var digit_text = BitmapTextScript.new()
	digit_text.configure(
		digit_texture,
		BitmapTextScript.DIGIT_CHARSET,
		BitmapTextScript.DIGIT_CELL_SIZE,
		BitmapTextScript.DIGIT_ADVANCES,
		BitmapTextScript.DIGIT_SPACE_ADVANCE
	)
	_assert(digit_text.measure_text("0") == 15, "bitmap digits use original zero width")
	_assert(digit_text.measure_text("1") == 13, "bitmap digits use original one width")
	_assert(digit_text.measure_text("885") == 45, "bitmap digits measure multi-digit high score")
	_assert(digit_text.bounds_for_text("885", Vector2(615, 18), HORIZONTAL_ALIGNMENT_RIGHT) == Rect2(Vector2(570, 18), Vector2(45, 20)), "bitmap digits support right-aligned bounds")


func _validate_menu_bitmap_label() -> void:
	var label = MenuBitmapLabelScript.new()
	label.size = Vector2(220, 32)
	label.text = "High Score"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	root.add_child(label)
	await process_frame

	_assert(label.call("font_texture") != null, "menu bitmap label loads the original Font sheet")
	_assert(label.call("rendered_lines") == ["High Score"], "menu bitmap label preserves single-line text")
	_assert(label.call("content_size") == Vector2(164, 24), "menu bitmap label measures single-line content with original font metrics")

	label.size = Vector2(110, 80)
	label.wrap_enabled = true
	label.text = "Start New Game"
	await process_frame
	_assert(label.call("rendered_lines") == ["Start", "New", "Game"], "menu bitmap label wraps multiline content against control width")
	var wrapped_size: Vector2 = label.call("content_size")
	_assert(wrapped_size.y == 72 and wrapped_size.x > 0.0 and wrapped_size.x <= 110.0, "menu bitmap label reports wrapped multiline bounds")

	label.queue_free()
	await process_frame


func _validate_game_hud_presentation() -> void:
	var hud: KrakoutGameHud = GameHudScript.new()

	_assert(hud.caption_texts() == ["Your Score", "Balls Left", "Level", "High Score"], "game hud exposes original status captions")
	_assert(hud.statistic_source_rect() == Rect2(Vector2.ZERO, Vector2(640, 39)), "game hud uses original Statistic header strip")
	var anchors: Dictionary = hud.value_anchor_positions()
	_assert(anchors["score_right"] == Vector2(137, 18), "game hud anchors score value under original caption")
	_assert(anchors["lives_center"] == Vector2(278, 18), "game hud anchors balls-left value under original caption")
	_assert(anchors["level_center"] == Vector2(420, 18), "game hud anchors level value under original caption")
	_assert(anchors["best_score_right"] == Vector2(615, 18), "game hud anchors high-score value under original caption")
	_assert(hud.header_value_text_bounds(0, anchors["score_right"], HORIZONTAL_ALIGNMENT_RIGHT) == Rect2(Vector2(119, 18), Vector2(18, 24)), "game hud right-aligns score value with original Font metrics")
	_assert(hud.header_value_text_bounds(3, anchors["lives_center"], HORIZONTAL_ALIGNMENT_CENTER) == Rect2(Vector2(268.5, 18), Vector2(19, 24)), "game hud centers balls-left value with original Font metrics")
	_assert(hud.header_value_text_bounds(1, anchors["level_center"], HORIZONTAL_ALIGNMENT_CENTER) == Rect2(Vector2(413, 18), Vector2(14, 24)), "game hud centers level value with original Font metrics")
	_assert(hud.header_value_text_bounds(885, anchors["best_score_right"], HORIZONTAL_ALIGNMENT_RIGHT) == Rect2(Vector2(561, 18), Vector2(54, 24)), "game hud right-aligns high-score value with original Font metrics")
	_assert(hud.status_digit_text_bounds(25, Vector2(576, 73), HORIZONTAL_ALIGNMENT_LEFT) == Rect2(Vector2(576, 73), Vector2(29, 20)), "game hud keeps gold digit metrics for timed status values")
	var first_status_layout: Dictionary = hud.status_indicator_layout(0)
	_assert(first_status_layout["icon_position"] == Vector2(543, 69), "game hud status icon starts at original x/y")
	_assert(first_status_layout["value_position"] == Vector2(576, 73), "game hud status value starts at original x/y")
	var second_status_layout: Dictionary = hud.status_indicator_layout(1)
	_assert(second_status_layout["icon_position"] == Vector2(543, 99), "game hud status icons step by original row height")
	_assert(hud.status_indicator_slots() == 6, "game hud exposes every InfoIcons status slot")
	var values: Dictionary = hud.status_values()
	_assert(values["score"] == 0, "game hud defaults score to zero")
	_assert(values["lives"] == 0, "game hud defaults spare balls to zero without a session")
	_assert(values["level"] == 1, "game hud defaults display level to one")
	_assert(values["best_score"] == 0, "game hud defaults high score to zero")
	_assert(not bool(hud.ready_prompt_layout().get("visible", false)), "game hud hides ready prompt without a session")
	_assert(not bool(hud.exit_confirmation_layout().get("visible", false)), "game hud hides leave-board confirmation by default")

	var ready_prompt_session = GameSessionScript.new()
	ready_prompt_session.display_level_number = 7
	hud.set_session(ready_prompt_session)
	_assert(not bool(hud.ready_prompt_layout().get("visible", false)), "game hud hides ready prompt after the finite level-start overlay")
	ready_prompt_session.start_level_ready_sequence(false)
	var ready_prompt_layout: Dictionary = hud.ready_prompt_layout()
	_assert(bool(ready_prompt_layout["visible"]), "game hud shows ready prompt during level-start overlay")
	_assert(ready_prompt_layout["level_text"] == "Level #7", "game hud renders original ready level text")
	_assert(ready_prompt_layout["ready_text"] == "Get Ready!", "game hud renders original get-ready text")
	_assert(ready_prompt_layout["hint_text"] == "(Press Mouse Button when ready)", "game hud renders original ready hint text")
	_assert(ready_prompt_layout["level_position"] == Vector2(320, 215), "game hud places ready level text at original y")
	_assert(ready_prompt_layout["ready_position"] == Vector2(320, 240), "game hud keeps get-ready text static at original y")
	_assert(ready_prompt_layout["hint_position"] == Vector2(320, 428), "game hud places ready hint at original y")
	ready_prompt_session.update(GameSessionScript.LEVEL_READY_ANIMATION_SECONDS * 0.5)
	var mid_ready_prompt_layout: Dictionary = hud.ready_prompt_layout()
	_assert(mid_ready_prompt_layout["ready_position"] == ready_prompt_layout["ready_position"], "game hud does not animate get-ready labels")
	var mid_roller_layout: Dictionary = ready_prompt_session.level_ready_roller_layout()
	_assert(bool(mid_roller_layout["visible"]), "level-ready roller remains visible while labels are visible")
	var mid_roller_destination: Rect2 = mid_roller_layout["destination"]
	_assert(mid_roller_destination.position.x > GameSessionScript.LEVEL_READY_ROLLER_POSITION.x, "level-ready roller carries the visible intro animation")
	ready_prompt_session.update(GameSessionScript.LEVEL_READY_ANIMATION_SECONDS * 0.5)
	_assert(not bool(hud.ready_prompt_layout().get("visible", false)), "game hud hides ready prompt when the level-start animation finishes")
	_assert(not bool(ready_prompt_session.level_ready_roller_layout().get("visible", false)), "level-ready roller hides with the labels")
	ready_prompt_session.start_level_ready_sequence(false)
	ready_prompt_session.launch_ready_ball()
	_assert(not bool(hud.ready_prompt_layout().get("visible", false)), "game hud hides ready prompt after launch")

	hud.set_exit_confirmation_visible(true)
	var exit_confirmation_layout: Dictionary = hud.exit_confirmation_layout()
	_assert(bool(exit_confirmation_layout["visible"]), "game hud exposes leave-board confirmation for bitmap drawing")
	_assert(exit_confirmation_layout["title_text"] == "Are You sure to leave", "game hud keeps original leave-board first line")
	_assert(exit_confirmation_layout["summary_text"] == "this board (Y / N)", "game hud keeps original leave-board second line")
	_assert(exit_confirmation_layout["title_position"] == Vector2(320, 215), "game hud places leave-board first line at original y")
	_assert(exit_confirmation_layout["summary_position"] == Vector2(320, 240), "game hud places leave-board second line at original y")
	hud.set_exit_confirmation_visible(false)
	_assert(not bool(hud.exit_confirmation_layout().get("visible", false)), "game hud hides leave-board confirmation when cleared")

	var game_over_session = GameSessionScript.new()
	game_over_session.state = GameSessionScript.STATE_GAME_OVER
	game_over_session.display_level_number = 3
	game_over_session.score = 45
	hud.set_session(game_over_session)
	var game_over_layout: Dictionary = hud.game_over_layout()
	_assert(bool(game_over_layout["visible"]), "game hud exposes game-over summary for bitmap drawing")
	_assert(game_over_layout["title_text"] == "Game Over!", "game hud keeps original game-over title")
	_assert(game_over_layout["summary_text"] == "Your Level #3, and Score 45", "game hud formats original game-over summary")
	_assert(game_over_layout["hint_text"] == "(Press Mouse Button to enter Menu)", "game hud keeps original game-over hint")
	_assert(game_over_layout["title_position"] == Vector2(320, 215), "game hud places game-over title at original y")
	_assert(game_over_layout["summary_position"] == Vector2(320, 240), "game hud places game-over summary at original y")
	_assert(game_over_layout["hint_position"] == Vector2(320, 428), "game hud places game-over hint at original y")
	hud.set_session(null)

	root.add_child(hud)
	await process_frame
	_assert(hud.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "game hud keeps atlas HUD textures unfiltered")
	hud.refresh()
	_assert(hud.find_child("GameOverTitle", true, false) == null, "game hud no longer creates native game-over title labels")
	_assert(hud.find_child("GameOverSummary", true, false) == null, "game hud no longer creates native game-over summary labels")
	var bitmap_status: Dictionary = hud.bitmap_text_status()
	_assert(bitmap_status["statistic_texture"], "game hud loads original Statistic header strip in tree")
	_assert(bitmap_status["digit_texture"], "game hud loads original Digits sheet in tree")
	_assert(bitmap_status["font_texture"], "game hud loads original Font sheet for fallback text in tree")
	_assert(bitmap_status["info_icons_texture"], "game hud loads original InfoIcons sheet in tree")
	_assert(bitmap_status["digit_text"], "game hud binds digit renderer after texture load")
	_assert(bitmap_status["font_text"], "game hud binds font renderer after texture load")
	hud.queue_free()


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
		"Digits",
		"DigitsSmall",
		"Exploision",
		"Fb",
		"Font",
		"InfoIcons",
		"Monsters",
		"PointToBonusInStack",
		"Racket",
		"Roller",
		"Snake",
		"Statistic",
		"Vx",
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


func _validate_menu_ambient_effects() -> void:
	_assert(
		MenuAmbientEffectsScript.star_source_rect(0) == Rect2(Vector2(0, 0), Vector2(30, 30)),
		"menu ambient maps first original star frame"
	)
	_assert(
		MenuAmbientEffectsScript.star_source_rect(10) == Rect2(Vector2(300, 0), Vector2(30, 30)),
		"menu ambient maps mid original star frame"
	)
	_assert(
		MenuAmbientEffectsScript.star_source_rect(19) == Rect2(Vector2(570, 0), Vector2(30, 30)),
		"menu ambient maps final original star frame"
	)
	_assert(
		MenuAmbientEffectsScript.star_source_rect(20) == Rect2(Vector2(0, 0), Vector2(30, 30)),
		"menu ambient star frame wraps after original frame count"
	)

	var generated_stars: Array[Dictionary] = MenuAmbientEffectsScript.generate_original_stars(31415)
	_assert(generated_stars.size() == MenuAmbientEffectsScript.STAR_COUNT, "menu ambient creates original star count")
	if not generated_stars.is_empty():
		var first_star: Dictionary = generated_stars[0]
		_assert(first_star["position"] == Vector2(194, 125), "menu ambient deterministic first star position matches original RNG")
		_assert(is_equal_approx(Vector2(first_star["speed"]).x, 40.837455), "menu ambient deterministic first star x speed matches original RNG")
		_assert(is_equal_approx(Vector2(first_star["speed"]).y, 49.070321), "menu ambient deterministic first star y speed matches original RNG")
		_assert(int(first_star["frame"]) == 6, "menu ambient deterministic first star initial frame matches original RNG")
		_assert(int(first_star["delay_ms"]) == 85, "menu ambient deterministic first star frame delay matches original RNG")

	var ambient = MenuAmbientEffectsScript.new()
	ambient.reset_original_state(31415)
	_assert(ambient.stars_snapshot().size() == MenuAmbientEffectsScript.STAR_COUNT, "menu ambient renderer resets star pool")
	_assert(ambient.direction_index() == 0, "menu ambient starts with original down-right drift")
	ambient.set_stars_for_test([{
		"position": Vector2(639, 479),
		"speed": Vector2(20, 40),
		"frame": 19,
		"delay_ms": 70,
		"frame_elapsed_ms": 0.0,
	}])
	ambient.advance(MenuAmbientEffectsScript.STAR_STEP_SECONDS)
	var moved_stars: Array[Dictionary] = ambient.stars_snapshot()
	_assert(moved_stars.size() == 1, "menu ambient preserves injected star")
	if moved_stars.size() == 1:
		_assert(Vector2(moved_stars[0]["position"]) == Vector2(-30, -30), "menu ambient wraps stars on original bounds")
		_assert(int(moved_stars[0]["frame"]) == 19, "menu ambient star frame waits for its own delay")
	ambient.advance(0.07 - MenuAmbientEffectsScript.STAR_STEP_SECONDS)
	moved_stars = ambient.stars_snapshot()
	if moved_stars.size() == 1:
		_assert(int(moved_stars[0]["frame"]) == 0, "menu ambient star frame wraps after original frame delay")

	ambient.set_stars_for_test([])
	ambient.reset_original_state(31415)
	ambient.set_stars_for_test([])
	ambient.advance(MenuAmbientEffectsScript.STAR_DIRECTION_SECONDS)
	_assert(ambient.direction_index() == 1, "menu ambient changes drift direction every ten seconds")
	ambient.advance(MenuAmbientEffectsScript.STAR_DIRECTION_SECONDS * 3.0)
	_assert(ambient.direction_index() == 0, "menu ambient drift direction cycles through four modes")

	ambient.reset_original_state(31415)
	ambient.set_stars_for_test([])
	_assert(ambient.title_target_rect() == Rect2(Vector2(122, 70), Vector2(396, 75)), "menu ambient title uses original base rect")
	_assert(MenuAmbientEffectsScript.title_source_rect_for_row(10) == Rect2(Vector2(0, 10), Vector2(396, 1)), "menu ambient title draws one source row")
	_assert(MenuAmbientEffectsScript.title_offset_for_row(0, 90.0) == 5, "menu ambient title wave reaches original positive amplitude")
	_assert(MenuAmbientEffectsScript.title_offset_for_row(10, 0.0) == 3, "menu ambient title wave uses per-row phase")
	ambient.advance(MenuAmbientEffectsScript.TITLE_PHASE_STEP_SECONDS)
	_assert(is_equal_approx(ambient.title_phase_degrees(), 0.0), "menu ambient title waits for original strict 20 ms gate")
	ambient.advance(0.001)
	_assert(is_equal_approx(ambient.title_phase_degrees(), 11.0), "menu ambient title advances once after original sampled gate")
	ambient.advance(0.1)
	_assert(is_equal_approx(ambient.title_phase_degrees(), 22.0), "menu ambient title discards overshoot like the original timer gate")
	ambient.free()


func _validate_options_vx_effects() -> void:
	_assert(
		OptionsScreenScript.sound_slider_track_source_rect() == Rect2(Vector2(0, 0), Vector2(198, 16)),
		"options screen maps original slider track cell"
	)
	_assert(
		OptionsScreenScript.sound_slider_handle_source_rect() == Rect2(Vector2(198, 0), Vector2(16, 38)),
		"options screen maps original slider handle cell"
	)
	_assert(
		OptionsScreenScript.backward_source_rect_for_frame(0) == Rect2(Vector2(0, 0), Vector2(100, 100)),
		"options screen maps original backward first frame"
	)
	_assert(
		OptionsScreenScript.backward_source_rect_for_frame(19) == Rect2(Vector2(0, 1900), Vector2(100, 100)),
		"options screen maps original backward final frame"
	)
	_assert(
		StaticMenuBackButtonScript.source_rect_for_frame(0) == Rect2(Vector2(0, 0), Vector2(100, 100)),
		"static menu back maps original backward first frame"
	)
	_assert(
		StaticMenuBackButtonScript.source_rect_for_frame(19) == Rect2(Vector2(0, 1900), Vector2(100, 100)),
		"static menu back maps original backward final frame"
	)
	_assert(
		OptionsScreenScript.page_arrow_source_rect_for_frame(9) == Rect2(Vector2(405, 0), Vector2(45, 45)),
		"options screen maps original page-arrow final frame"
	)
	var options_arrow_probe = OptionsScreenScript.new()
	options_arrow_probe.call("_set_hovered_control", OptionsScreenScript.CONTROL_PAGE_DOWN)
	options_arrow_probe.call("_process", OptionsScreenScript.PAGE_ARROW_FRAME_SECONDS)
	_assert(
		int(options_arrow_probe.call("page_down_arrow_frame")) == 0,
		"options screen hovered page arrow waits for the strict original 30 ms gate"
	)
	options_arrow_probe.call("_process", 0.001)
	_assert(
		int(options_arrow_probe.call("page_down_arrow_frame")) == 1,
		"options screen hovered page arrow advances once after the original sampled gate"
	)
	_assert(
		int(options_arrow_probe.call("page_up_arrow_frame")) == 0,
		"options screen non-hovered page arrow stays on its idle frame"
	)
	options_arrow_probe.call("_set_hovered_control", "")
	_assert(
		int(options_arrow_probe.call("page_down_arrow_frame")) == 1,
		"options screen page arrow keeps its current frame when hover leaves"
	)
	options_arrow_probe.call("_process", OptionsScreenScript.PAGE_ARROW_RETURN_FRAME_SECONDS + 0.001)
	_assert(
		int(options_arrow_probe.call("page_down_arrow_frame")) == 2,
		"options screen page arrow continues its cycle after hover leaves"
	)
	for _options_arrow_finish_step in range(OptionsScreenScript.PAGE_ARROW_FRAME_COUNT - 2):
		options_arrow_probe.call("_process", OptionsScreenScript.PAGE_ARROW_RETURN_FRAME_SECONDS + 0.001)
	_assert(
		int(options_arrow_probe.call("page_down_arrow_frame")) == 0,
		"options screen page arrow stops after finishing its unhovered cycle"
	)
	options_arrow_probe.free()
	var static_back_probe = StaticMenuBackButtonScript.new()
	static_back_probe.call("_set_hovered", true)
	static_back_probe.call("advance", StaticMenuBackButtonScript.SELECTED_FRAME_GATE_SECONDS)
	_assert(int(static_back_probe.call("current_frame")) == 0, "static back button waits for the strict original hover gate")
	static_back_probe.call("advance", 0.001)
	_assert(int(static_back_probe.call("current_frame")) == 1, "static back button advances while hovered")
	static_back_probe.call("_set_hovered", false)
	_assert(int(static_back_probe.call("current_frame")) == 1, "static back button keeps its current frame when hover leaves")
	static_back_probe.call("advance", StaticMenuBackButtonScript.RETURN_FRAME_GATE_SECONDS + 0.001)
	_assert(int(static_back_probe.call("current_frame")) == 2, "static back button continues its cycle after hover leaves")
	for _static_back_finish_step in range(StaticMenuBackButtonScript.FRAME_COUNT - 2):
		static_back_probe.call("advance", StaticMenuBackButtonScript.RETURN_FRAME_GATE_SECONDS + 0.001)
	_assert(int(static_back_probe.call("current_frame")) == 0, "static back button stops after finishing its unhovered cycle")
	static_back_probe.free()
	_assert(
		OptionsScreenScript.original_audio_slider_handle_x_for_volume(0) == 362,
		"options screen keeps original volume-slider minimum handle x"
	)
	_assert(
		OptionsScreenScript.original_audio_slider_handle_x_for_volume(100) == 521,
		"options screen keeps original volume-slider maximum handle x"
	)
	_assert(
		OptionsScreenScript.original_audio_volume_for_mouse_x(370.0) == 0,
		"options screen keeps original mouse-to-volume mapping at minimum"
	)
	_assert(
		OptionsScreenScript.original_audio_volume_for_mouse_x(537.0) == 100,
		"options screen clamps original mouse-to-volume mapping at maximum"
	)
	_assert(
		OptionsScreenScript.original_audio_control_ids() == [
			OptionsScreenScript.CONTROL_MUSIC_TOGGLE,
			OptionsScreenScript.CONTROL_SFX_TOGGLE,
			OptionsScreenScript.CONTROL_MUSIC_SLIDER,
			OptionsScreenScript.CONTROL_SFX_SLIDER,
		],
		"options screen exposes the original four-control audio panel contract"
	)
	_assert(
		OptionsScreenScript.original_options_control_id_for_hit_index(OptionsScreenScript.ORIGINAL_OPTIONS_HIT_MUSIC_TOGGLE)
			== OptionsScreenScript.CONTROL_MUSIC_TOGGLE,
		"options screen maps original hit 128 to the music toggle"
	)
	_assert(
		OptionsScreenScript.original_options_control_id_for_hit_index(OptionsScreenScript.ORIGINAL_OPTIONS_HIT_SFX_TOGGLE)
			== OptionsScreenScript.CONTROL_SFX_TOGGLE,
		"options screen maps original hit 129 to the SFX toggle"
	)
	_assert(
		OptionsScreenScript.original_options_control_id_for_hit_index(OptionsScreenScript.ORIGINAL_OPTIONS_HIT_MUSIC_SLIDER)
			== OptionsScreenScript.CONTROL_MUSIC_SLIDER,
		"options screen maps original hit 130 to the music slider"
	)
	_assert(
		OptionsScreenScript.original_options_control_id_for_hit_index(OptionsScreenScript.ORIGINAL_OPTIONS_HIT_SFX_SLIDER)
			== OptionsScreenScript.CONTROL_SFX_SLIDER,
		"options screen maps original hit 131 to the SFX slider"
	)
	_assert(
		OptionsScreenScript.original_options_hit_index(Vector2(560, 237)) == OptionsScreenScript.ORIGINAL_OPTIONS_HIT_MUSIC_TOGGLE,
		"options screen decodes the original music-toggle hit index"
	)
	_assert(
		OptionsScreenScript.original_options_hit_index(Vector2(590, 267)) == OptionsScreenScript.ORIGINAL_OPTIONS_HIT_MUSIC_TOGGLE,
		"options screen keeps the original inclusive music-toggle hit edge"
	)
	_assert(
		OptionsScreenScript.original_options_hit_index(Vector2(560, 297)) == OptionsScreenScript.ORIGINAL_OPTIONS_HIT_SFX_TOGGLE,
		"options screen decodes the original SFX-toggle hit index"
	)
	_assert(
		OptionsScreenScript.original_options_hit_index(Vector2(370, 233)) == OptionsScreenScript.ORIGINAL_OPTIONS_HIT_MUSIC_SLIDER,
		"options screen decodes the original music-slider hit index"
	)
	_assert(
		OptionsScreenScript.original_options_hit_index(Vector2(537, 271)) == OptionsScreenScript.ORIGINAL_OPTIONS_HIT_MUSIC_SLIDER,
		"options screen keeps the original inclusive music-slider hit edge"
	)
	_assert(
		OptionsScreenScript.original_options_hit_index(Vector2(370, 293)) == OptionsScreenScript.ORIGINAL_OPTIONS_HIT_SFX_SLIDER,
		"options screen decodes the original SFX-slider hit index"
	)
	_assert(
		OptionsScreenScript.original_options_hit_index(Vector2(537, 331)) == OptionsScreenScript.ORIGINAL_OPTIONS_HIT_SFX_SLIDER,
		"options screen keeps the original inclusive SFX-slider hit edge"
	)
	_assert(
		OptionsScreenScript.original_options_hit_index(Vector2(591, 267)) == OptionsScreenScript.ORIGINAL_OPTIONS_NO_HIT,
		"options screen rejects points outside the original hit table"
	)
	_assert(
		OptionsVxEffectsScript.source_rect_for_frame(0) == Rect2(Vector2(0, 0), Vector2(40, 40)),
		"options Vx maps original first animation frame"
	)
	_assert(
		OptionsVxEffectsScript.source_rect_for_frame(9) == Rect2(Vector2(360, 0), Vector2(40, 40)),
		"options Vx maps original final animation frame"
	)
	_assert(
		OptionsVxEffectsScript.source_rect_for_frame(99) == Rect2(Vector2(360, 0), Vector2(40, 40)),
		"options Vx clamps animation frames to the original range"
	)
	_assert(
		OptionsVxEffectsScript.static_source_rect() == Rect2(Vector2(400, 0), Vector2(30, 30)),
		"options Vx maps original static marker cell"
	)

	var vx_effects = OptionsVxEffectsScript.new()
	vx_effects.set_row_base_y(OptionsVxEffectsScript.ROW_MUSIC, 222.0)
	vx_effects.set_music_enabled(false, true)
	_assert(
		int(vx_effects.current_frame(OptionsVxEffectsScript.ROW_MUSIC)) == OptionsVxEffectsScript.DISABLED_TARGET_FRAME,
		"options Vx snaps disabled music indicator to original final frame"
	)
	_assert(
		vx_effects.indicator_rect(OptionsVxEffectsScript.ROW_MUSIC) == Rect2(Vector2(555, 231), Vector2(40, 40)),
		"options Vx places animated music indicator beside the slider"
	)
	_assert(
		vx_effects.static_indicator_rect(OptionsVxEffectsScript.ROW_MUSIC) == Rect2(Vector2(560, 237), Vector2(30, 30)),
		"options Vx places static music marker at the original relative offset"
	)
	vx_effects.set_music_enabled(true)
	_assert(
		int(vx_effects.target_frame(OptionsVxEffectsScript.ROW_MUSIC)) == OptionsVxEffectsScript.ENABLED_TARGET_FRAME,
		"options Vx targets original first frame when music is enabled"
	)
	vx_effects.advance(OptionsVxEffectsScript.FRAME_SECONDS)
	_assert(
		int(vx_effects.current_frame(OptionsVxEffectsScript.ROW_MUSIC)) == OptionsVxEffectsScript.DISABLED_TARGET_FRAME,
		"options Vx waits for the original strict 30 ms gate"
	)
	vx_effects.advance(0.001)
	_assert(
		int(vx_effects.current_frame(OptionsVxEffectsScript.ROW_MUSIC)) == OptionsVxEffectsScript.DISABLED_TARGET_FRAME - 1,
		"options Vx advances one frame toward enabled state after the original sampled gate"
	)
	for _step in range(OptionsVxEffectsScript.FRAME_COUNT):
		vx_effects.advance(OptionsVxEffectsScript.FRAME_SECONDS + 0.001)
	_assert(
		int(vx_effects.current_frame(OptionsVxEffectsScript.ROW_MUSIC)) == OptionsVxEffectsScript.ENABLED_TARGET_FRAME,
		"options Vx reaches the original first frame when fully enabled"
	)
	vx_effects.set_music_enabled(false)
	vx_effects.advance(OptionsVxEffectsScript.FRAME_SECONDS)
	_assert(
		int(vx_effects.current_frame(OptionsVxEffectsScript.ROW_MUSIC)) == OptionsVxEffectsScript.ENABLED_TARGET_FRAME,
		"options Vx waits for the original strict gate when returning to disabled state"
	)
	vx_effects.advance(0.001)
	_assert(
		int(vx_effects.current_frame(OptionsVxEffectsScript.ROW_MUSIC)) == 1,
		"options Vx advances one frame toward disabled state after the sampled gate"
	)
	vx_effects.configure_row_count(4)
	vx_effects.set_row_base_y(3, 230.0)
	vx_effects.set_row_enabled(3, true, true)
	_assert(
		vx_effects.static_indicator_rect(3) == Rect2(Vector2(560, 245), Vector2(30, 30)),
		"options Vx supports additional custom rows for the second page"
	)
	vx_effects.free()


func _validate_menu_and_game_scenes() -> void:
	var saved_mouse_mode := Input.get_mouse_mode()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if _audio != null:
		if _audio.has_method("set_sfx_enabled"):
			_audio.call("set_sfx_enabled", true)
		if _audio.has_method("set_sfx_volume"):
			_audio.call("set_sfx_volume", 100)
		if _audio.has_method("stop_all"):
			_audio.call("stop_all")

	_assert(ResourceLoader.exists("res://scenes/menu/main_menu_screen.tscn"), "main menu scene exists")
	_assert(ResourceLoader.exists("res://scenes/menu/episode_select_screen.tscn"), "episode select scene exists")
	_assert(ResourceLoader.exists("res://scenes/menu/rules_screen.tscn"), "rules scene exists")
	_assert(ResourceLoader.exists("res://scenes/menu/high_score_screen.tscn"), "high score scene exists")
	_assert(ResourceLoader.exists("res://scenes/menu/name_entry_screen.tscn"), "name entry scene exists")
	_assert(ResourceLoader.exists("res://scenes/menu/options_screen.tscn"), "options scene exists")
	_assert(ResourceLoader.exists("res://scenes/menu/credits_screen.tscn"), "credits scene exists")
	_assert(ResourceLoader.exists("res://scenes/menu/exit_confirm_screen.tscn"), "exit confirmation scene exists")
	_assert(ResourceLoader.exists("res://scenes/game/game_screen.tscn"), "game screen scene exists")

	var menu := MainMenuScreenScene.instantiate()
	root.add_child(menu)
	await process_frame
	await process_frame

	_assert(menu.has_signal("start_game_requested"), "main menu exposes start game signal")
	_assert(menu.has_signal("rules_requested"), "main menu exposes rules signal")
	_assert(menu.has_signal("high_score_requested"), "main menu exposes high score signal")
	_assert(menu.has_signal("options_requested"), "main menu exposes options signal")
	_assert(menu.has_signal("credits_requested"), "main menu exposes credits signal")
	_assert(menu.has_signal("quit_requested"), "main menu exposes quit signal")
	_assert(menu.find_child("Background", true, false) != null, "main menu creates background art")
	var static_title := menu.find_child("Title", true, false) as TextureRect
	_assert(static_title != null, "main menu keeps legacy title node")
	if static_title != null:
		_assert(not static_title.visible, "main menu hides static title in favor of original ambient renderer")
	var ambient_effects = menu.find_child("MenuAmbientEffects", true, false)
	_assert(ambient_effects != null, "main menu creates original ambient VFX renderer")
	if ambient_effects != null:
		_assert(ambient_effects.stars_snapshot().size() == MenuAmbientEffectsScript.STAR_COUNT, "main menu ambient VFX owns original star pool")
		_assert(ambient_effects.title_target_rect() == Rect2(Vector2(122, 70), Vector2(396, 75)), "main menu ambient VFX owns title draw rect")
	var selected_caption = menu.find_child("SelectedCaption", true, false)
	_assert(selected_caption != null, "main menu creates selected caption")
	if selected_caption != null:
		_assert(selected_caption.get_script() == MenuBitmapLabelScript, "main menu renders its selected caption with the original bitmap font")

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
		_assert(menu.call("selected_caption") == "", "main menu hides the status caption until a button is hovered")
	if selected_caption != null:
		_assert(String(selected_caption.get("text")) == "", "main menu starts with no visible status caption")
	if _audio != null and _audio.has_method("is_sfx_playing"):
		_assert(not bool(_audio.call("is_sfx_playing", "eff01")), "main menu startup stays silent")
		_assert(not bool(_audio.call("is_sfx_playing", "eff02")), "main menu deferred focus stays silent")

	var start_button := menu.find_child("StartGameButton", true, false) as TextureButton
	_assert(start_button != null, "main menu creates start game button")
	if start_button != null:
		menu.call("reset_menu_button_animation")
		_assert(int(menu.call("menu_item_frame", "start")) == 0, "main menu icon animation resets to first frame")
		menu.call("_process", MainMenuScreenScript.ICON_SELECTED_FRAME_GATE_SECONDS + 0.001)
		_assert(int(menu.call("menu_item_frame", "start")) == 0, "main menu selected icon does not animate without hover")
		start_button.emit_signal("mouse_entered")
		if selected_caption != null:
			_assert(String(selected_caption.get("text")) == "Start New Game", "main menu shows status caption while the start icon is hovered")
		menu.call("_process", MainMenuScreenScript.ICON_SELECTED_FRAME_GATE_SECONDS)
		_assert(int(menu.call("menu_item_frame", "start")) == 0, "main menu hovered icon waits for original strict 20 ms gate")
		menu.call("_process", 0.001)
		_assert(int(menu.call("menu_item_frame", "start")) == 1, "main menu hovered icon advances once after original sampled gate")
		start_button.emit_signal("mouse_exited")
		if selected_caption != null:
			_assert(String(selected_caption.get("text")) == "", "main menu clears status caption when the start icon is unhovered")
		_assert(int(menu.call("menu_item_frame", "start")) == 1, "main menu icon keeps its current frame when hover leaves")
		menu.call("_process", MainMenuScreenScript.ICON_RETURN_FRAME_GATE_SECONDS + 0.001)
		_assert(int(menu.call("menu_item_frame", "start")) == 2, "main menu icon continues its cycle after hover leaves")
		for _main_menu_finish_step in range(MainMenuScreenScript.ICON_FRAME_COUNT - 2):
			menu.call("_process", MainMenuScreenScript.ICON_RETURN_FRAME_GATE_SECONDS + 0.001)
		_assert(int(menu.call("menu_item_frame", "start")) == 0, "main menu icon stops after finishing its unhovered cycle")
		if _audio != null and _audio.has_method("stop_all") and _audio.has_method("is_sfx_playing"):
			_audio.call("stop_all")
		menu.call("_select_menu_item", "rules")
		if _audio != null and _audio.has_method("is_sfx_playing"):
			_assert(bool(_audio.call("is_sfx_playing", "eff02")), "main menu selection change plays original hover cue")
			_audio.call("stop_all")
			menu.call("_select_menu_item", "rules")
			_assert(not bool(_audio.call("is_sfx_playing", "eff02")), "main menu does not replay hover cue when selection is unchanged")
		menu.call("_process", MainMenuScreenScript.ICON_SELECTED_FRAME_GATE_SECONDS + 0.001)
		_assert(int(menu.call("menu_item_frame", "rules")) == 0, "main menu newly selected icon stays idle without hover")
		if selected_caption != null:
			menu.call("_select_menu_item", "rules")
			_assert(String(selected_caption.get("text")) == "", "main menu keeps status caption hidden for focus-only selection changes")
			var caption_rules_button := menu.find_child("RulesButton", true, false) as TextureButton
			if caption_rules_button != null:
				caption_rules_button.emit_signal("mouse_entered")
				_assert(String(selected_caption.get("text")) == "Game Rules", "main menu updates bitmap caption text on hover")
				caption_rules_button.emit_signal("mouse_exited")
				_assert(String(selected_caption.get("text")) == "", "main menu clears bitmap caption text on unhover")

	var signal_state := {"did_request_start": false}
	menu.start_game_requested.connect(func() -> void: signal_state["did_request_start"] = true)
	if _audio != null and _audio.has_method("stop_all"):
		_audio.call("stop_all")
	if start_button != null:
		start_button.emit_signal("pressed")
	_assert(signal_state["did_request_start"], "start game button emits start request")
	if _audio != null and _audio.has_method("is_sfx_playing"):
		_assert(bool(_audio.call("is_sfx_playing", "eff01")), "main menu activation plays original confirm cue")

	var rules_button := menu.find_child("RulesButton", true, false) as TextureButton
	if rules_button != null:
		var rules_signal_state := {"did_request_rules": false}
		menu.rules_requested.connect(func() -> void: rules_signal_state["did_request_rules"] = true)
		rules_button.emit_signal("pressed")
		await process_frame
		_assert(rules_signal_state["did_request_rules"], "rules button emits stub request")
	var high_score_button := menu.find_child("HighScoreButton", true, false) as TextureButton
	if high_score_button != null:
		var high_score_signal_state := {"did_request_high_score": false}
		menu.high_score_requested.connect(func() -> void: high_score_signal_state["did_request_high_score"] = true)
		high_score_button.emit_signal("pressed")
		await process_frame
		_assert(high_score_signal_state["did_request_high_score"], "high-score button emits request")
	var options_button := menu.find_child("OptionsButton", true, false) as TextureButton
	if options_button != null:
		var options_signal_state := {"did_request_options": false}
		menu.options_requested.connect(func() -> void: options_signal_state["did_request_options"] = true)
		options_button.emit_signal("pressed")
		await process_frame
		_assert(options_signal_state["did_request_options"], "options button emits request")
	var credits_button := menu.find_child("CreditsButton", true, false) as TextureButton
	if credits_button != null:
		var credits_signal_state := {"did_request_credits": false}
		menu.credits_requested.connect(func() -> void: credits_signal_state["did_request_credits"] = true)
		credits_button.emit_signal("pressed")
		await process_frame
		_assert(credits_signal_state["did_request_credits"], "credits button emits request")
	menu.queue_free()

	var exit_confirm := ExitConfirmScreenScene.instantiate()
	root.add_child(exit_confirm)
	await process_frame
	_assert(exit_confirm.has_signal("exit_confirmed"), "exit confirmation screen exposes confirm signal")
	_assert(exit_confirm.has_signal("back_requested"), "exit confirmation screen exposes back signal")
	_assert(exit_confirm.find_child("Background", true, false) != null, "exit confirmation screen creates background art")
	var exit_ambient_effects = exit_confirm.find_child("MenuAmbientEffects", true, false)
	_assert(exit_ambient_effects != null, "exit confirmation screen keeps original ambient VFX")
	if exit_ambient_effects != null:
		_assert(exit_ambient_effects.title_target_rect() == Rect2(Vector2(122, 70), Vector2(396, 75)), "exit confirmation ambient VFX owns title draw rect")
	var confirm_exit_button := exit_confirm.find_child("ConfirmExitButton", true, false) as TextureButton
	_assert(confirm_exit_button != null, "exit confirmation screen creates original Exit icon button")
	if confirm_exit_button != null:
		_assert(confirm_exit_button.position == ExitConfirmScreenScript.EXIT_BUTTON_POSITION, "exit confirmation confirm icon uses original coordinate")
		_assert(confirm_exit_button.texture_normal is AtlasTexture, "exit confirmation confirm icon uses the main menu atlas")
		if confirm_exit_button.texture_normal is AtlasTexture:
			var confirm_texture := confirm_exit_button.texture_normal as AtlasTexture
			_assert(confirm_texture.region == ExitConfirmScreenScript.exit_icon_source_rect_for_frame(0), "exit confirmation confirm icon starts on original Exit frame")
		exit_confirm.call("reset_exit_button_animation")
		confirm_exit_button.emit_signal("mouse_entered")
		exit_confirm.call("_process", ExitConfirmScreenScript.ICON_SELECTED_FRAME_GATE_SECONDS)
		_assert(int(exit_confirm.call("exit_button_frame")) == 0, "exit confirmation confirm icon waits for original strict 20 ms gate")
		exit_confirm.call("_process", 0.001)
		_assert(int(exit_confirm.call("exit_button_frame")) == 1, "exit confirmation confirm icon advances once after original sampled gate")
	var confirm_back_button = exit_confirm.find_child("BackButton", true, false)
	_assert(confirm_back_button != null and confirm_back_button.get_script() == StaticMenuBackButtonScript, "exit confirmation screen creates original Backward cancel button")
	if confirm_back_button != null:
		_assert(confirm_back_button.position == ExitConfirmScreenScript.BACK_BUTTON_POSITION, "exit confirmation Backward icon uses original coordinate")
	var exit_confirm_signal_state := {"confirmed": false, "back": false}
	exit_confirm.exit_confirmed.connect(func() -> void: exit_confirm_signal_state["confirmed"] = true)
	exit_confirm.back_requested.connect(func() -> void: exit_confirm_signal_state["back"] = true)
	if _audio != null and _audio.has_method("stop_all"):
		_audio.call("stop_all")
	if confirm_exit_button != null:
		confirm_exit_button.emit_signal("pressed")
		_assert(exit_confirm_signal_state["confirmed"], "exit confirmation confirm button emits confirm signal")
		if _audio != null and _audio.has_method("is_sfx_playing"):
			_assert(bool(_audio.call("is_sfx_playing", "eff01")), "exit confirmation confirm plays original activate cue")
	if _audio != null and _audio.has_method("stop_all"):
		_audio.call("stop_all")
	if confirm_back_button != null and confirm_back_button.has_method("activate"):
		confirm_back_button.call("activate")
		_assert(exit_confirm_signal_state["back"], "exit confirmation Backward button emits back signal")
		if _audio != null and _audio.has_method("is_sfx_playing"):
			_assert(bool(_audio.call("is_sfx_playing", "eff01")), "exit confirmation back plays original activate cue")
	exit_confirm.queue_free()

	if _profile != null and _profile.has_method("set_save_path"):
		_profile.call("set_save_path", _test_profile_path("menu_screens"), false)
	if _profile != null and _profile.has_method("set_best_score"):
		_profile.call("set_best_score", 321)

	var rules_screen := RulesScreenScene.instantiate()
	root.add_child(rules_screen)
	await process_frame
	_assert(rules_screen.has_signal("back_requested"), "rules screen exposes back signal")
	var rules_back_button = rules_screen.find_child("BackButton", true, false)
	_assert(rules_back_button != null and rules_back_button.get_script() == StaticMenuBackButtonScript, "rules screen creates original Backward art button")
	_assert(rules_screen.find_children("*", "Button", true, false).is_empty(), "rules screen no longer creates a native back button")
	_assert(String(rules_screen.call("screen_title")) == "Game Rules", "rules screen exposes title")
	var rules_title = rules_screen.find_child("TitleLabel", true, false)
	var rules_body = rules_screen.find_child("BodyLabel", true, false)
	var rules_hint = rules_screen.find_child("ScrollHintLabel", true, false)
	var rules_scroll_view = rules_screen.find_child("RulesScrollView", true, false)
	_assert(rules_title != null and rules_title.get_script() == MenuBitmapLabelScript, "rules screen renders title with original bitmap font")
	_assert(rules_body != null and rules_body.get_script() == MenuBitmapLabelScript, "rules screen renders body copy with original bitmap font")
	_assert(rules_hint != null and rules_hint.get_script() == MenuBitmapLabelScript and String(rules_hint.text) == "Use Up/Down/PgUp/PgDn to scroll.", "rules screen renders original footer scroll hint label")
	_assert(rules_scroll_view != null, "rules screen creates original clipped scroll area")
	if rules_title != null:
		_assert(rules_title.position == RulesScreenScript.TITLE_POSITION, "rules screen keeps original title y coordinate")
	if rules_hint != null:
		_assert(rules_hint.position == RulesScreenScript.HINT_POSITION, "rules screen keeps original footer scroll hint coordinate")
	if rules_scroll_view != null:
		_assert(rules_scroll_view.position == RulesScreenScript.VIEW_POSITION, "rules screen scroll clipping starts at original y=50")
		_assert(rules_scroll_view.size == RulesScreenScript.VIEW_SIZE, "rules screen scroll clipping ends at original y=435")
	if rules_back_button != null:
		_assert(rules_back_button.position == RulesScreenScript.BACK_POSITION, "rules screen Backward art uses original rules coordinate")
	var rules_lines: Array = rules_screen.call("body_lines")
	_assert(rules_lines.has("--==| | Game Rules and Keys | |==--"), "rules screen uses original executable heading")
	_assert(rules_lines.has("-=| Game Overview |=-"), "rules screen includes original game overview section")
	_assert(rules_lines.has("Control Racket with Mouse and let"), "rules screen includes original overview copy")
	_assert(rules_lines.has("-=| Keys used in Game |=-"), "rules screen includes original key section")
	_assert(rules_lines.has("<Ctrl> + <U> - Release cursor."), "rules screen includes original cursor-release key copy")
	_assert(rules_lines.has("<Space> - Use Bonus."), "rules screen includes original bonus-use key copy")
	_assert(rules_lines.has("-=| Bonuses |=-"), "rules screen includes original bonuses section")
	var rules_bonus_names: Array = rules_screen.call("bonus_names")
	_assert(rules_bonus_names.size() == GameSessionScript.BONUS_TYPE_COUNT, "rules screen lists every original bonus")
	_assert(String(rules_bonus_names[0]) == "Add standard Ball", "rules screen preserves first executable bonus name")
	_assert(String(rules_bonus_names[21]) == "Explode all Explodings", "rules screen preserves final executable bonus name")
	var first_bonus_icon := rules_screen.find_child("BonusIcon0", true, false) as TextureRect
	var final_bonus_icon := rules_screen.find_child("BonusIcon21", true, false) as TextureRect
	_assert(first_bonus_icon != null and first_bonus_icon.texture is AtlasTexture, "rules screen draws first original bonus icon from atlas")
	_assert(final_bonus_icon != null and final_bonus_icon.texture is AtlasTexture, "rules screen draws final original bonus icon from atlas")
	if first_bonus_icon != null:
		_assert(first_bonus_icon.position.x == RulesScreenScript.BONUS_ICON_X, "rules screen first bonus icon uses original x coordinate")
	_assert(RulesScreenScript.bonus_icon_source_rect(0, 0) == Rect2(Vector2(0, 0), Vector2(32, 32)), "rules screen bonus atlas starts at first type/frame cell")
	_assert(RulesScreenScript.bonus_icon_source_rect(21, 9) == Rect2(Vector2(672, 288), Vector2(32, 32)), "rules screen bonus atlas maps original 22x10 sheet orientation")
	rules_screen.call("reset_bonus_icon_animation")
	_assert(int(rules_screen.call("bonus_icon_frame", 0)) == 0, "rules screen bonus animation starts on frame zero")
	rules_screen.call("advance_bonus_icon_animation", RulesScreenScript.BONUS_ICON_FRAME_SECONDS)
	_assert(int(rules_screen.call("bonus_icon_frame", 0)) == 0, "rules screen bonus animation keeps the original strict 50 ms gate")
	rules_screen.call("advance_bonus_icon_animation", 0.001)
	_assert(int(rules_screen.call("bonus_icon_frame", 0)) == 1, "rules screen bonus animation advances after the original 50 ms gate")
	_assert(is_equal_approx(float(rules_screen.call("max_scroll_offset")), 1140.0), "rules screen exposes the original 50 to -1090 scroll range")
	var rules_scroll_start := float(rules_screen.call("scroll_offset"))
	var rules_down_event := InputEventKey.new()
	rules_down_event.keycode = KEY_DOWN
	rules_down_event.pressed = true
	rules_screen.call("_unhandled_input", rules_down_event)
	_assert(is_equal_approx(float(rules_screen.call("scroll_offset")), rules_scroll_start), "rules screen arrow key press itself does not perform one-shot scrolling")
	rules_screen.call("advance_scroll_key_state", false, true)
	_assert(is_equal_approx(float(rules_screen.call("scroll_offset")), rules_scroll_start + RulesScreenScript.SCROLL_LINE_PIXELS), "rules screen scrolls down by original 3px held-key step")
	rules_screen.call("advance_scroll_key_state", false, true)
	_assert(is_equal_approx(float(rules_screen.call("scroll_offset")), rules_scroll_start + RulesScreenScript.SCROLL_LINE_PIXELS * 2.0), "rules screen keeps scrolling while Down is held")
	rules_screen.call("advance_scroll_key_state", true, false)
	_assert(is_equal_approx(float(rules_screen.call("scroll_offset")), rules_scroll_start + RulesScreenScript.SCROLL_LINE_PIXELS), "rules screen keeps scrolling upward while Up is held")
	var rules_after_down := float(rules_screen.call("scroll_offset"))
	var rules_page_down_event := InputEventKey.new()
	rules_page_down_event.keycode = KEY_PAGEDOWN
	rules_page_down_event.pressed = true
	rules_screen.call("_unhandled_input", rules_page_down_event)
	_assert(is_equal_approx(float(rules_screen.call("scroll_offset")), rules_after_down + RulesScreenScript.PAGE_SCROLL_PIXELS), "rules screen scrolls by original 400px page-down step")
	rules_screen.call("scroll_by", 100000.0)
	_assert(is_equal_approx(float(rules_screen.call("scroll_offset")), float(rules_screen.call("max_scroll_offset"))), "rules screen clamps scroll at the bottom")
	var rules_page_up_event := InputEventKey.new()
	rules_page_up_event.keycode = KEY_PAGEUP
	rules_page_up_event.pressed = true
	rules_screen.call("_unhandled_input", rules_page_up_event)
	_assert(float(rules_screen.call("scroll_offset")) < float(rules_screen.call("max_scroll_offset")), "rules screen scrolls upward with page-up key")
	if _audio != null and _audio.has_method("is_sfx_playing"):
		if _audio.has_method("stop_all"):
			_audio.call("stop_all")
		_assert(not bool(_audio.call("is_sfx_playing", "eff01")), "rules screen startup stays silent for activation cue")
		var rules_back_signal_state := {"requested": false}
		rules_screen.back_requested.connect(func() -> void: rules_back_signal_state["requested"] = true)
		if rules_back_button != null:
			rules_back_button.call("activate")
		_assert(bool(rules_back_signal_state["requested"]), "rules screen original Back button emits back request")
		_assert(bool(_audio.call("is_sfx_playing", "eff01")), "rules screen original Back button plays front-end activation cue")
		if _audio.has_method("stop_all"):
			_audio.call("stop_all")
	rules_screen.queue_free()

	var credits_screen := CreditsScreenScene.instantiate()
	root.add_child(credits_screen)
	await process_frame
	_assert(credits_screen.has_signal("back_requested"), "credits screen exposes back signal")
	var credits_back_button = credits_screen.find_child("BackButton", true, false)
	_assert(credits_back_button != null and credits_back_button.get_script() == StaticMenuBackButtonScript, "credits screen creates original Backward art button")
	_assert(credits_screen.find_children("*", "Button", true, false).is_empty(), "credits screen no longer creates a native back button")
	if credits_back_button != null:
		_assert(credits_back_button.position == Vector2(539, 379), "credits screen places Backward button at the original credits position")
	_assert(String(credits_screen.call("screen_title")) == "Credits", "credits screen exposes title")
	var credits_title = credits_screen.find_child("TitleLabel", true, false)
	var credits_body = credits_screen.find_child("BodyLabel", true, false)
	_assert(credits_title == null, "credits screen does not add a non-original static title label")
	_assert(credits_body != null and credits_body.get_script() == MenuBitmapLabelScript, "credits screen renders rolling body copy with original bitmap font")
	var credit_sections: Array = credits_screen.call("credit_sections")
	_assert(credit_sections.size() == 5, "credits screen exposes original executable credit groups")
	_assert(String(credit_sections[0]["role"]) == "Main Programmer", "credits screen preserves original programmer role")
	var programmer_names: Array = credit_sections[0]["names"]
	_assert(programmer_names.has("Andrey A. Ugolnik"), "credits screen preserves original programmer credit")
	var design_names: Array = credit_sections[1]["names"]
	_assert(design_names.has("Eugene P. Janushkevich"), "credits screen preserves original design and graphics co-credit")
	_assert(String(credit_sections[2]["role"]) == "Levels Designers", "credits screen preserves original level-designer role")
	var level_designer_names: Array = credit_sections[2]["names"]
	_assert(level_designer_names.has("Eugene P. Janushkevich"), "credits screen preserves original level-designer credit")
	var beta_tester_names: Array = credit_sections[3]["names"]
	_assert(beta_tester_names.has("Ludmila N. Ugolnik"), "credits screen preserves original beta-tester credit")
	_assert(String(credit_sections[4]["role"]) == "Original Music", "credits screen preserves original music role")
	var music_names: Array = credit_sections[4]["names"]
	_assert(music_names.has("Konstantin Elgazin"), "credits screen preserves original music credit")
	var credit_footer_lines: Array = credits_screen.call("credit_footer_lines")
	_assert(credit_footer_lines.has("(c) 2001-2002 'WE' Group."), "credits screen preserves original copyright line")
	_assert(credit_footer_lines.has("All Rights Reserved."), "credits screen preserves original rights line")
	_assert(credit_footer_lines.has("http://www.wegroup.org"), "credits screen preserves original website line")
	var credit_lines: Array = credits_screen.call("body_lines")
	_assert(not credit_lines.has("Reimplementation:"), "credits screen no longer shows placeholder reimplementation copy")
	credits_screen.call("set_credits_scroll_y_for_test", CreditsScreenScript.ORIGINAL_CREDITS_ROLL_START_Y)
	_assert(
		is_equal_approx(float(credits_screen.call("credits_scroll_y")), CreditsScreenScript.ORIGINAL_CREDITS_ROLL_START_Y),
		"credits screen starts the original auto-roll below the viewport"
	)
	credits_screen.call("advance_credits_roll", CreditsScreenScript.ORIGINAL_CREDITS_ROLL_STEP_SECONDS - 0.001)
	_assert(
		is_equal_approx(float(credits_screen.call("credits_scroll_y")), CreditsScreenScript.ORIGINAL_CREDITS_ROLL_START_Y),
		"credits screen waits for the original strict roll timer gate"
	)
	credits_screen.call("advance_credits_roll", 0.001)
	_assert(
		is_equal_approx(float(credits_screen.call("credits_scroll_y")), CreditsScreenScript.ORIGINAL_CREDITS_ROLL_START_Y - 1.0),
		"credits screen advances the roll by one pixel after the original timer gate"
	)
	credits_screen.call("set_credits_scroll_y_for_test", CreditsScreenScript.ORIGINAL_CREDITS_ROLL_WRAP_Y)
	credits_screen.call("advance_credits_roll", CreditsScreenScript.ORIGINAL_CREDITS_ROLL_STEP_SECONDS)
	_assert(
		is_equal_approx(float(credits_screen.call("credits_scroll_y")), CreditsScreenScript.ORIGINAL_CREDITS_ROLL_START_Y),
		"credits screen wraps the original roll below the executable cutoff"
	)
	var credits_scroll_start := float(credits_screen.call("credits_scroll_y"))
	var credits_down_event := InputEventKey.new()
	credits_down_event.keycode = KEY_DOWN
	credits_down_event.pressed = true
	credits_screen.call("_unhandled_input", credits_down_event)
	_assert(
		is_equal_approx(float(credits_screen.call("credits_scroll_y")), credits_scroll_start),
		"credits screen ignores manual key scrolling like the original auto-roll"
	)
	if _audio != null and _audio.has_method("is_sfx_playing"):
		if _audio.has_method("stop_all"):
			_audio.call("stop_all")
		var credits_back_signal_state := {"requested": false}
		credits_screen.back_requested.connect(func() -> void: credits_back_signal_state["requested"] = true)
		var cancel_event := InputEventAction.new()
		cancel_event.action = "ui_cancel"
		cancel_event.pressed = true
		credits_screen.call("_unhandled_input", cancel_event)
		_assert(bool(credits_back_signal_state["requested"]), "credits screen Escape emits original Back request")
		_assert(bool(_audio.call("is_sfx_playing", "eff01")), "credits screen Escape plays front-end activation cue")
		if _audio.has_method("stop_all"):
			_audio.call("stop_all")
	credits_screen.queue_free()

	var high_score_screen := HighScoreScreenScene.instantiate()
	root.add_child(high_score_screen)
	await process_frame
	_assert(high_score_screen.has_signal("back_requested"), "high score screen exposes back signal")
	var high_score_back_button = high_score_screen.find_child("BackButton", true, false)
	_assert(high_score_back_button != null and high_score_back_button.get_script() == StaticMenuBackButtonScript, "high score screen creates original Backward art button")
	if high_score_back_button != null:
		_assert(high_score_back_button.position == Vector2(539, 379), "high score screen places Backward button at the original table position")
	_assert(high_score_screen.find_children("*", "Button", true, false).is_empty(), "high score screen no longer creates a native back button")
	_assert(int(high_score_screen.call("best_score")) == 321, "high score screen reads persisted high score")
	var high_score_entries: Array = high_score_screen.call("high_score_entries")
	_assert(high_score_entries.size() == 1, "high score screen reads profile table entries")
	_assert(high_score_entries[0]["score"] == 321, "high score screen mirrors legacy best in table view")
	var high_score_table := high_score_screen.find_child("HighScoreTable", true, false)
	_assert(high_score_table != null, "high score screen builds a structured bitmap-text table")
	var high_score_header = high_score_screen.find_child("HeaderName", true, false)
	var high_score_value = high_score_screen.find_child("EntryScore1", true, false)
	_assert(high_score_header != null and high_score_header.get_script() == MenuBitmapLabelScript, "high score screen renders table headers with original bitmap font")
	_assert(high_score_header != null and high_score_header.position == Vector2(50, 80), "high score screen places headers at original coordinates")
	_assert(high_score_value != null and String(high_score_value.get("text")) == "321", "high score screen renders score values in fixed bitmap-text columns")
	_assert(high_score_value != null and high_score_value.position == Vector2(465, 125), "high score screen right-anchors score values at original x=555")
	var high_score_footer = high_score_screen.find_child("EpisodeHoverHint", true, false)
	_assert(high_score_footer != null and String(high_score_footer.get("text")) == "Use cursor to view episode name.", "high score screen shows original episode-name hover hint")
	high_score_screen.queue_free()

	if _profile != null and _profile.has_method("submit_high_score"):
		_profile.call("submit_high_score", "Wave", 777, 5, "Retro")
	var highlighted_high_score := HighScoreScreenScene.instantiate()
	if highlighted_high_score.has_method("configure_highlight_entry"):
		highlighted_high_score.call("configure_highlight_entry", {
			"name": "Wave",
			"score": 777,
			"level": 5,
			"episode": "Retro",
		})
	root.add_child(highlighted_high_score)
	await process_frame
	_assert(int(highlighted_high_score.call("highlighted_row_index")) == 0, "high score screen highlights the newly submitted original row")
	var wave_overlay := highlighted_high_score.find_child("HighScoreWaveOverlay", true, false)
	_assert(wave_overlay != null, "high score screen creates original row-wave overlay")
	var wave_name = highlighted_high_score.find_child("WaveName", true, false)
	_assert(wave_name != null and wave_name.get_script() == WaveBitmapLabelScript, "high score screen renders highlighted row with sine-wave bitmap text")
	if wave_name != null:
		_assert(String(wave_name.get("text")) == "Wave", "high score wave label mirrors highlighted player name")
		_assert(wave_name.position == Vector2(50, 120), "high score wave label preserves original row baseline with 5px amplitude room")
	highlighted_high_score.call("reset_high_score_vfx_for_test")
	highlighted_high_score.call("advance_high_score_vfx", HighScoreScreen.ROW_WAVE_STEP_SECONDS)
	_assert(is_equal_approx(float(highlighted_high_score.call("row_wave_phase_degrees")), 0.0), "high score row wave waits for the original strict 40 ms gate")
	highlighted_high_score.call("advance_high_score_vfx", 0.001)
	_assert(is_equal_approx(float(highlighted_high_score.call("row_wave_phase_degrees")), 20.0), "high score row wave advances by the original 20 degree step")
	highlighted_high_score.call("set_hover_probe_for_test", Vector2(60, HighScoreScreen.TABLE_ROW_START_Y + 1.0))
	_assert(String(highlighted_high_score.call("hovered_episode_text")) == "Retro", "high score screen shows the hovered row episode name")
	highlighted_high_score.call("set_hover_probe_for_test", Vector2(60, HighScoreScreen.TABLE_ROW_START_Y))
	_assert(String(highlighted_high_score.call("hovered_episode_text")).is_empty(), "high score hover uses the original strict row boundary")
	highlighted_high_score.queue_free()

	var name_entry_screen := NameEntryScreenScene.instantiate()
	root.add_child(name_entry_screen)
	await process_frame
	_assert(name_entry_screen.has_signal("score_submitted"), "name entry screen exposes score-submitted signal")
	_assert(name_entry_screen.has_signal("cancel_requested"), "name entry screen exposes cancel signal")
	_assert(name_entry_screen.find_child("NameLabel", true, false) != null, "name entry screen creates editable name label")
	_assert(name_entry_screen.find_child("SubmitButton", true, false) == null, "name entry screen does not invent a visible submit button")
	_assert(name_entry_screen.find_child("CancelButton", true, false) == null, "name entry screen does not invent a visible cancel button")
	_assert(name_entry_screen.find_children("*", "Button", true, false).is_empty(), "name entry screen stays keyboard-driven like the original")
	var entry_name_label = name_entry_screen.find_child("NameLabel", true, false)
	var prompt_label = name_entry_screen.find_child("PromptLabel", true, false)
	var backspace_hint_label = name_entry_screen.find_child("BackspaceHintLabel", true, false)
	var enter_hint_label = name_entry_screen.find_child("EnterHintLabel", true, false)
	_assert(entry_name_label != null and entry_name_label.get_script() == MenuBitmapLabelScript, "name entry screen renders editable name with original bitmap font")
	_assert(prompt_label != null and prompt_label.get_script() == MenuBitmapLabelScript, "name entry screen renders prompt with original bitmap font")
	_assert(backspace_hint_label != null and backspace_hint_label.get_script() == MenuBitmapLabelScript, "name entry screen renders Backspace hint with original bitmap font")
	_assert(enter_hint_label != null and enter_hint_label.get_script() == MenuBitmapLabelScript, "name entry screen renders Enter hint with original bitmap font")
	if prompt_label != null and entry_name_label != null and backspace_hint_label != null and enter_hint_label != null:
		_assert(prompt_label.position == NameEntryScreenScript.PROMPT_POSITION, "name entry prompt uses original y=5 placement")
		_assert(entry_name_label.position == NameEntryScreenScript.NAME_POSITION, "name entry editable text uses original y=215 placement")
		_assert(backspace_hint_label.position == NameEntryScreenScript.BACKSPACE_HINT_POSITION, "name entry Backspace hint uses original y=430 placement")
		_assert(enter_hint_label.position == NameEntryScreenScript.ENTER_HINT_POSITION, "name entry Enter hint uses original y=455 placement")
		_assert(String(prompt_label.text) == NameEntryScreenScript.PROMPT_TEXT, "name entry keeps original prompt text")
		_assert(String(backspace_hint_label.text) == NameEntryScreenScript.BACKSPACE_HINT_TEXT, "name entry keeps original Backspace hint")
		_assert(String(enter_hint_label.text) == NameEntryScreenScript.ENTER_HINT_TEXT, "name entry keeps original Enter hint")
	_assert(
		NameEntryScreenScript.primary_background_source_rect() == Rect2(Vector2(0, 0), Vector2(48, 48)),
		"name entry background maps original first BgGetName tile"
	)
	_assert(
		NameEntryScreenScript.secondary_background_source_rect() == Rect2(Vector2(48, 0), Vector2(48, 48)),
		"name entry background maps original second BgGetName tile"
	)
	_assert(
		NameEntryScreenScript.primary_background_target_rect(Vector2.ZERO, 0) == Rect2(Vector2(0, -48), Vector2(48, 48)),
		"name entry primary background starts one tile up like the original draw loop"
	)
	_assert(
		NameEntryScreenScript.secondary_background_target_rect(Vector2.ZERO, 0) == Rect2(Vector2(-48, -48), Vector2(48, 48)),
		"name entry secondary background starts diagonally offset like the original draw loop"
	)
	_assert(
		NameEntryScreenScript.primary_background_target_rect(Vector2.ZERO, 1) == Rect2(Vector2(0, -47), Vector2(48, 48)),
		"name entry primary background scrolls vertically by the original one-pixel step"
	)
	_assert(
		NameEntryScreenScript.secondary_background_target_rect(Vector2.ZERO, 3) == Rect2(Vector2(-45, -45), Vector2(48, 48)),
		"name entry secondary background scrolls diagonally by the original three-pixel step"
	)
	name_entry_screen.call("reset_original_state")
	var background_offsets: Dictionary = name_entry_screen.call("background_offsets")
	_assert(int(background_offsets["primary"]) == 0 and int(background_offsets["secondary"]) == 0, "name entry background starts at original zero offsets")
	name_entry_screen.call("advance", NameEntryScreenScript.BACKGROUND_SCROLL_STEP_SECONDS)
	background_offsets = name_entry_screen.call("background_offsets")
	_assert(int(background_offsets["primary"]) == 0 and int(background_offsets["secondary"]) == 0, "name entry background waits for strict 30 ms sampled gate")
	name_entry_screen.call("advance", 0.001)
	background_offsets = name_entry_screen.call("background_offsets")
	_assert(int(background_offsets["primary"]) == 1, "name entry primary background advances by original one-pixel step")
	_assert(int(background_offsets["secondary"]) == 3, "name entry secondary background advances by original three-pixel step")
	for _background_step in range(47):
		name_entry_screen.call("advance", NameEntryScreenScript.BACKGROUND_SCROLL_STEP_SECONDS + 0.001)
	background_offsets = name_entry_screen.call("background_offsets")
	_assert(int(background_offsets["primary"]) == 0, "name entry primary background wraps at the original 48px tile size")
	_assert(int(background_offsets["secondary"]) == 0, "name entry secondary background wraps at the original 48px tile size")
	name_entry_screen.call("reset_original_state")
	_assert(bool(name_entry_screen.call("name_cursor_visible")), "name entry cursor starts visible")
	_assert(String(name_entry_screen.call("name_display_text")) == "_", "name entry displays the original visible cursor for empty input")
	name_entry_screen.call("advance", NameEntryScreenScript.NAME_CURSOR_BLINK_SECONDS)
	_assert(bool(name_entry_screen.call("name_cursor_visible")), "name entry cursor waits for strict 400 ms blink gate")
	name_entry_screen.call("advance", 0.001)
	_assert(not bool(name_entry_screen.call("name_cursor_visible")), "name entry cursor toggles after original sampled blink gate")
	_assert(String(name_entry_screen.call("name_display_text")) == " ", "name entry hidden cursor uses the original trailing space")
	_assert(not AudioCueCatalogScript.has_sfx_event("name_entry_submit"), "name entry submit stays silent without an original SFX route")
	name_entry_screen.call("configure", 456, 7, "Retro", "Retro")
	name_entry_screen.call("_unhandled_input", _key_event(KEY_A, 65))
	name_entry_screen.call("_unhandled_input", _key_event(KEY_B, 66))
	await process_frame
	_assert(String(name_entry_screen.call("current_player_name")) == "AB", "name entry screen accepts printable key input")
	name_entry_screen.call("_unhandled_input", _key_event(KEY_BACKSPACE))
	await process_frame
	_assert(String(name_entry_screen.call("current_player_name")) == "A", "name entry screen routes Backspace editing")
	var name_entry_signal_state := {
		"submitted": false,
		"name": "",
		"score": 0,
		"level": 0,
		"episode": "",
	}
	name_entry_screen.score_submitted.connect(func(player_name: String, score: int, level_number: int, episode_slug: String) -> void:
		name_entry_signal_state["submitted"] = true
		name_entry_signal_state["name"] = player_name
		name_entry_signal_state["score"] = score
		name_entry_signal_state["level"] = level_number
		name_entry_signal_state["episode"] = episode_slug
	)
	name_entry_screen.call("_unhandled_input", _key_event(KEY_ENTER))
	await process_frame
	_assert(name_entry_signal_state["submitted"], "name entry screen routes Enter confirmation")
	_assert(name_entry_signal_state["name"] == "A", "name entry screen submits typed name")
	_assert(name_entry_signal_state["score"] == 456, "name entry screen submits score")
	_assert(name_entry_signal_state["level"] == 7, "name entry screen submits reached level")
	_assert(name_entry_signal_state["episode"] == "Retro", "name entry screen submits episode slug")
	name_entry_screen.call("set_player_name", "")
	_assert(String(name_entry_screen.call("submitted_player_name")) == "Anonymous", "name entry screen defaults empty names to Anonymous")
	name_entry_screen.queue_free()

	if _profile != null:
		_profile.call("set_music_enabled", false)
		_profile.call("set_sfx_enabled", false)
		_profile.call("set_fullscreen_enabled", false)
		_profile.call("set_music_volume", 25)
		_profile.call("set_sfx_volume", 45)
		_profile.call("set_bonus_stack_visible", false)
		_profile.call("set_ball_tracks_visible", false)
		_profile.call("set_fps_visible", true)
		_profile.call("set_background_movable", false)
		_profile.call("set_background_type", 7)

	var options_screen := OptionsScreenScene.instantiate()
	root.add_child(options_screen)
	await process_frame
	_assert(options_screen.has_signal("back_requested"), "options screen exposes back signal")
	_assert(options_screen.find_children("*", "CheckButton", true, false).is_empty(), "options screen no longer uses native check buttons")
	_assert(options_screen.find_children("*", "HSlider", true, false).is_empty(), "options screen no longer uses native sliders")
	var options_title_label = options_screen.find_child("TitleLabel", true, false)
	var options_music_label = options_screen.find_child("MusicVolumeLabel", true, false)
	_assert(options_title_label != null and options_title_label.get_script() == MenuBitmapLabelScript, "options screen renders its title with the original bitmap font")
	_assert(options_music_label != null and options_music_label.get_script() == MenuBitmapLabelScript, "options screen renders audio labels with the original bitmap font")
	var options_vx_effects = options_screen.find_child("OptionsVxEffects", true, false)
	_assert(options_vx_effects != null, "options screen creates original Vx effects overlay")
	var options_page_two_vx = options_screen.find_child("OptionsPageTwoVxEffects", true, false)
	_assert(options_page_two_vx != null, "options screen creates second-page original Vx effects overlay")
	var options_page_three_vx = options_screen.find_child("OptionsPageThreeVxEffects", true, false)
	_assert(options_page_three_vx != null, "options screen creates third-page original Vx effects overlay")
	_assert(options_screen.find_child("BackButton", true, false) == null, "options screen replaces the generic back button with original art")
	_assert(options_screen.find_child("PreviewSfxButton", true, false) == null, "options screen does not expose provisional SFX preview")
	_assert(int(options_screen.call("page_count")) == 3, "options screen exposes three custom pages")
	_assert(int(options_screen.call("current_page")) == 0, "options screen starts on the audio controls page")
	_assert(
		options_screen.call("visible_control_ids") == [
			OptionsScreenScript.CONTROL_MUSIC_SLIDER,
			OptionsScreenScript.CONTROL_SFX_SLIDER,
			OptionsScreenScript.CONTROL_MUSIC_TOGGLE,
			OptionsScreenScript.CONTROL_SFX_TOGGLE,
			OptionsScreenScript.CONTROL_PAGE_DOWN,
			OptionsScreenScript.CONTROL_BACKWARD,
		],
		"options screen exposes original audio-page control order"
	)
	_assert(
		options_screen.call("control_hit_rect", OptionsScreenScript.CONTROL_MUSIC_SLIDER) == Rect2(Vector2(370, 233), Vector2(167, 38)),
		"options screen keeps original music-slider hitbox"
	)
	_assert(
		options_screen.call("control_hit_rect", OptionsScreenScript.CONTROL_MUSIC_TOGGLE) == Rect2(Vector2(560, 237), Vector2(30, 30)),
		"options screen keeps original music-toggle hitbox"
	)
	_assert(
		options_screen.call("control_hit_rect", OptionsScreenScript.CONTROL_SFX_SLIDER) == Rect2(Vector2(370, 293), Vector2(167, 38)),
		"options screen keeps original SFX-slider hitbox"
	)
	_assert(
		options_screen.call("control_hit_rect", OptionsScreenScript.CONTROL_SFX_TOGGLE) == Rect2(Vector2(560, 297), Vector2(30, 30)),
		"options screen keeps original SFX-toggle hitbox"
	)
	_assert(
		options_screen.call("_control_at_position", Vector2(590, 267)) == OptionsScreenScript.CONTROL_MUSIC_TOGGLE,
		"options screen routes audio-page edge clicks through the original music-toggle decoder"
	)
	_assert(
		options_screen.call("_control_at_position", Vector2(537, 271)) == OptionsScreenScript.CONTROL_MUSIC_SLIDER,
		"options screen routes audio-page edge clicks through the original music-slider decoder"
	)
	_assert(
		options_screen.call("_control_at_position", Vector2(537, 331)) == OptionsScreenScript.CONTROL_SFX_SLIDER,
		"options screen routes audio-page edge clicks through the original SFX-slider decoder"
	)
	var options_snapshot: Dictionary = options_screen.call("settings_snapshot")
	_assert(not bool(options_snapshot["music_enabled"]), "options screen loads music enabled setting")
	_assert(not bool(options_snapshot["sfx_enabled"]), "options screen loads SFX enabled setting")
	_assert(not bool(options_snapshot["fullscreen_enabled"]), "options screen loads fullscreen setting")
	_assert(int(options_snapshot["music_volume"]) == 25, "options screen loads music volume")
	_assert(int(options_snapshot["sfx_volume"]) == 45, "options screen loads SFX volume")
	_assert(not bool(options_snapshot["bonus_stack_visible"]), "options screen loads bonus-stack setting")
	_assert(not bool(options_snapshot["ball_tracks_visible"]), "options screen loads ball-track setting")
	_assert(bool(options_snapshot["fps_visible"]), "options screen loads FPS setting")
	_assert(not bool(options_snapshot["background_movable"]), "options screen loads background-movable setting")
	_assert(int(options_snapshot["background_type"]) == 7, "options screen loads full-range background type")
	if _audio != null and _audio.has_method("is_sfx_playing"):
		_assert(not bool(_audio.call("is_sfx_playing", "eff01")), "options screen startup stays silent for activation cue")
		_assert(not bool(_audio.call("is_sfx_playing", "eff02")), "options screen startup stays silent for selection cue")
		_audio.call("set_sfx_enabled", true)
		_audio.call("set_sfx_volume", 100)
		if _audio.has_method("stop_all"):
			_audio.call("stop_all")
		options_screen.call("select_control", OptionsScreenScript.CONTROL_MUSIC_SLIDER)
		_assert(not bool(_audio.call("is_sfx_playing", "eff02")), "options screen does not replay selection cue for unchanged control")
		options_screen.call("select_control", OptionsScreenScript.CONTROL_SFX_SLIDER)
		_assert(bool(_audio.call("is_sfx_playing", "eff02")), "options screen selection change plays original front-end hover cue")
		if _audio.has_method("stop_all"):
			_audio.call("stop_all")
		options_screen.call("select_control", OptionsScreenScript.CONTROL_SFX_SLIDER)
		_assert(not bool(_audio.call("is_sfx_playing", "eff02")), "options screen repeated selection stays silent")
		options_screen.call("select_control", OptionsScreenScript.CONTROL_PAGE_DOWN)
		if _audio.has_method("stop_all"):
			_audio.call("stop_all")
		_assert(bool(options_screen.call("_activate_control", OptionsScreenScript.CONTROL_PAGE_DOWN)), "options screen accepts page-down activation")
		_assert(int(options_screen.call("current_page")) == 1, "options screen page-down activation changes page")
		_assert(bool(_audio.call("is_sfx_playing", "eff01")), "options screen page activation plays original front-end confirm cue")
		if _audio.has_method("stop_all"):
			_audio.call("stop_all")
		options_screen.call("select_control", OptionsScreenScript.CONTROL_FPS_TOGGLE)
		if _audio.has_method("stop_all"):
			_audio.call("stop_all")
		_assert(bool(options_screen.call("_activate_control", OptionsScreenScript.CONTROL_FPS_TOGGLE)), "options screen accepts toggle activation")
		_assert(bool(_audio.call("is_sfx_playing", "eff01")), "options screen toggle activation plays original front-end confirm cue")
		if _audio.has_method("stop_all"):
			_audio.call("stop_all")
		options_screen.call("go_to_page", 0)
		var options_back_signal_state := {"requested": false}
		options_screen.back_requested.connect(func() -> void: options_back_signal_state["requested"] = true)
		options_screen.call("select_control", OptionsScreenScript.CONTROL_BACKWARD)
		if _audio.has_method("stop_all"):
			_audio.call("stop_all")
		_assert(bool(options_screen.call("_activate_control", OptionsScreenScript.CONTROL_BACKWARD)), "options screen accepts Back activation")
		_assert(bool(options_back_signal_state["requested"]), "options screen Back activation emits back request")
		_assert(bool(_audio.call("is_sfx_playing", "eff01")), "options screen Back activation plays original front-end confirm cue")
		if _audio.has_method("stop_all"):
			_audio.call("stop_all")
		_assert(not bool(options_screen.call("_activate_control", OptionsScreenScript.CONTROL_PAGE_UP)), "options screen rejects unavailable page-up activation")
		_assert(not bool(_audio.call("is_sfx_playing", "eff01")), "options screen failed page activation stays silent")
		options_screen.call("select_control", OptionsScreenScript.CONTROL_MUSIC_SLIDER)
		if _audio.has_method("stop_all"):
			_audio.call("stop_all")
		options_screen.call("_adjust_selected_control", 1)
		_assert(not bool(_audio.call("is_sfx_playing", "eff01")), "options screen slider adjustment does not play activation cue")
		_assert(not bool(_audio.call("is_sfx_playing", "eff02")), "options screen slider adjustment does not play selection cue")
		options_screen.call("set_music_volume", 25)
	_assert(
		options_screen.call("slider_handle_rect", OptionsScreenScript.CONTROL_MUSIC_SLIDER) == Rect2(Vector2(401, 233), Vector2(16, 38)),
		"options screen places the music slider handle from original volume math"
	)
	_assert(
		options_screen.call("slider_handle_rect", OptionsScreenScript.CONTROL_SFX_SLIDER) == Rect2(Vector2(433, 293), Vector2(16, 38)),
		"options screen places the SFX slider handle from original volume math"
	)
	if options_vx_effects != null:
		_assert(
			int(options_vx_effects.current_frame(OptionsVxEffectsScript.ROW_MUSIC)) == OptionsVxEffectsScript.DISABLED_TARGET_FRAME,
			"options screen snaps disabled music Vx state from profile"
		)
		_assert(
			int(options_vx_effects.current_frame(OptionsVxEffectsScript.ROW_SFX)) == OptionsVxEffectsScript.DISABLED_TARGET_FRAME,
			"options screen snaps disabled SFX Vx state from profile"
		)
	options_screen.call("set_music_enabled", true)
	options_screen.call("set_sfx_enabled", true)
	options_screen.call("set_fullscreen_enabled", true)
	options_screen.call("set_music_volume", 55)
	options_screen.call("set_sfx_volume", 65)
	options_screen.call("set_bonus_stack_visible", true)
	options_screen.call("set_ball_tracks_visible", true)
	options_screen.call("set_fps_visible", false)
	options_screen.call("set_background_movable", true)
	options_screen.call("set_background_type", 7)
	if options_vx_effects != null:
		_assert(
			int(options_vx_effects.target_frame(OptionsVxEffectsScript.ROW_MUSIC)) == OptionsVxEffectsScript.ENABLED_TARGET_FRAME,
			"options screen retargets music Vx when music is enabled"
		)
		_assert(
			int(options_vx_effects.target_frame(OptionsVxEffectsScript.ROW_SFX)) == OptionsVxEffectsScript.ENABLED_TARGET_FRAME,
			"options screen retargets SFX Vx when SFX is enabled"
		)
		options_vx_effects.advance(OptionsVxEffectsScript.FRAME_SECONDS)
		_assert(
			int(options_vx_effects.current_frame(OptionsVxEffectsScript.ROW_MUSIC)) == OptionsVxEffectsScript.DISABLED_TARGET_FRAME,
			"options screen waits for the strict original Vx gate"
		)
		options_vx_effects.advance(0.001)
		_assert(
			int(options_vx_effects.current_frame(OptionsVxEffectsScript.ROW_MUSIC)) == OptionsVxEffectsScript.DISABLED_TARGET_FRAME - 1,
			"options screen advances music Vx toward enabled state"
		)
		options_screen.call("select_control", OptionsScreenScript.CONTROL_BACKWARD)
		options_screen.call("_set_hovered_control", OptionsScreenScript.CONTROL_BACKWARD)
		options_screen.call("_process", OptionsScreenScript.BACKWARD_SELECTED_FRAME_GATE_SECONDS)
		_assert(int(options_screen.call("backward_frame")) == 0, "options screen backward button waits for the strict 20 ms hover gate")
		options_screen.call("_process", 0.001)
		_assert(int(options_screen.call("backward_frame")) == 1, "options screen backward button advances after the original hover gate")
		options_screen.call("select_control", OptionsScreenScript.CONTROL_MUSIC_SLIDER)
		options_screen.call("_set_hovered_control", "")
		_assert(int(options_screen.call("backward_frame")) == 1, "options screen backward button keeps its current frame when hover leaves")
		options_screen.call("_process", OptionsScreenScript.BACKWARD_RETURN_FRAME_GATE_SECONDS + 0.001)
		_assert(int(options_screen.call("backward_frame")) == 2, "options screen backward button continues its cycle after hover leaves")
		for _options_back_finish_step in range(OptionsScreenScript.BACKWARD_FRAME_COUNT - 2):
			options_screen.call("_process", OptionsScreenScript.BACKWARD_RETURN_FRAME_GATE_SECONDS + 0.001)
		_assert(int(options_screen.call("backward_frame")) == 0, "options screen backward button stops after finishing its unhovered cycle")
	options_screen.call("go_to_page", 1)
	_assert(int(options_screen.call("current_page")) == 1, "options screen switches to the presentation page")
	_assert(
		options_screen.call("visible_control_ids") == [
			OptionsScreenScript.CONTROL_FULLSCREEN_TOGGLE,
			OptionsScreenScript.CONTROL_FPS_TOGGLE,
			OptionsScreenScript.CONTROL_BACKGROUND_MOVABLE_TOGGLE,
			OptionsScreenScript.CONTROL_BACKGROUND_TYPE_SLIDER,
			OptionsScreenScript.CONTROL_PAGE_UP,
			OptionsScreenScript.CONTROL_PAGE_DOWN,
			OptionsScreenScript.CONTROL_BACKWARD,
		],
		"options screen exposes presentation-page control order"
	)
	_assert(
		options_screen.call("selected_control_id") == OptionsScreenScript.CONTROL_FULLSCREEN_TOGGLE,
		"options screen defaults presentation page selection to the fullscreen toggle"
	)
	if options_page_two_vx != null:
		_assert(int(options_page_two_vx.target_frame(0)) == OptionsVxEffectsScript.ENABLED_TARGET_FRAME, "options screen retargets fullscreen Vx state after toggling")
		_assert(int(options_page_two_vx.current_frame(1)) == OptionsVxEffectsScript.ENABLED_TARGET_FRAME, "options screen snaps enabled FPS Vx state from profile")
		_assert(int(options_page_two_vx.target_frame(2)) == OptionsVxEffectsScript.ENABLED_TARGET_FRAME, "options screen retargets moving-background Vx state after toggling")
	options_screen.call("go_to_page", 2)
	_assert(int(options_screen.call("current_page")) == 2, "options screen switches to the utility page")
	_assert(
		options_screen.call("visible_control_ids") == [
			OptionsScreenScript.CONTROL_BONUS_STACK_TOGGLE,
			OptionsScreenScript.CONTROL_BALL_TRACKS_TOGGLE,
			OptionsScreenScript.CONTROL_PAGE_UP,
			OptionsScreenScript.CONTROL_BACKWARD,
		],
		"options screen exposes utility-page control order"
	)
	_assert(
		options_screen.call("selected_control_id") == OptionsScreenScript.CONTROL_BONUS_STACK_TOGGLE,
		"options screen defaults utility page selection to the first gameplay toggle"
	)
	if options_page_three_vx != null:
		_assert(int(options_page_three_vx.target_frame(0)) == OptionsVxEffectsScript.ENABLED_TARGET_FRAME, "options screen retargets bonus-stack Vx state after toggling")
		_assert(int(options_page_three_vx.target_frame(1)) == OptionsVxEffectsScript.ENABLED_TARGET_FRAME, "options screen retargets ball-tracks Vx state after toggling")
	await process_frame
	if _profile != null:
		_assert(bool(_profile.call("music_enabled")), "options screen persists enabled music")
		_assert(bool(_profile.call("sfx_enabled")), "options screen persists enabled SFX")
		_assert(bool(_profile.call("fullscreen_enabled")), "options screen persists enabled fullscreen")
		_assert(int(_profile.call("music_volume")) == 55, "options screen persists music volume")
		_assert(int(_profile.call("sfx_volume")) == 65, "options screen persists SFX volume")
		_assert(bool(_profile.call("bonus_stack_visible")), "options screen persists bonus-stack setting")
		_assert(bool(_profile.call("ball_tracks_visible")), "options screen persists ball-track setting")
		_assert(not bool(_profile.call("fps_visible")), "options screen persists FPS setting")
		_assert(bool(_profile.call("background_movable")), "options screen persists background-movable setting")
		_assert(int(_profile.call("background_type")) == 7, "options screen persists full-range background type")
	options_screen.call("set_background_type", 99)
	_assert(int(options_screen.call("settings_snapshot")["background_type"]) == 0, "options screen normalizes out-of-range background types to the original first entry")
	if _profile != null:
		_assert(int(_profile.call("background_type")) == 0, "options screen persists normalized out-of-range background type")
	if _audio != null:
		_assert(bool(_audio.call("music_enabled")), "options screen syncs audio music enabled")
		_assert(bool(_audio.call("sfx_enabled")), "options screen syncs audio SFX enabled")
		_assert(int(_audio.call("music_volume")) == 55, "options screen syncs audio music volume")
		_assert(int(_audio.call("sfx_volume")) == 65, "options screen syncs audio SFX volume")
	options_screen.call("go_to_page", 0)
	_assert(int(options_screen.call("current_page")) == 0, "options screen can return from later settings pages to the audio page")
	options_screen.queue_free()

	var episode_select := EpisodeSelectScreenScene.instantiate()
	if _audio != null and _audio.has_method("stop_all"):
		_audio.call("stop_all")
	root.add_child(episode_select)
	await process_frame
	await process_frame

	_assert(episode_select.has_signal("episode_selected"), "episode select exposes episode selected signal")
	_assert(episode_select.has_signal("back_requested"), "episode select exposes back signal")
	_assert(episode_select.call("episode_count") == 17, "episode select lists all extracted episodes")
	_assert(episode_select.call("page_count") == 2, "episode select paginates extracted episodes")
	_assert(episode_select.call("visible_row_count") == 10, "episode select shows ten rows on first page")
	_assert(episode_select.find_child("PageStatus", true, false) != null, "episode select creates page status")
	_assert(episode_select.find_child("UpButton", true, false) != null, "episode select creates up arrow")
	_assert(episode_select.find_child("DownButton", true, false) != null, "episode select creates down arrow")
	var episode_up_button = episode_select.find_child("UpButton", true, false) as TextureButton
	var episode_down_button = episode_select.find_child("DownButton", true, false) as TextureButton
	_assert(
		episode_up_button != null
		and episode_down_button != null
		and episode_up_button.focus_mode == Control.FOCUS_NONE
		and episode_down_button.focus_mode == Control.FOCUS_NONE,
		"episode select arrows disable native Godot focus highlights"
	)
	_assert(
		episode_up_button != null
		and episode_down_button != null
		and episode_up_button.texture_normal is AtlasTexture
		and episode_down_button.texture_normal is AtlasTexture
		and (episode_up_button.texture_normal as AtlasTexture).atlas != (episode_down_button.texture_normal as AtlasTexture).atlas,
		"episode select keeps separate up and down arrow atlases after runtime transparency processing"
	)
	_assert(
		EpisodeSelectScreenScript.up_arrow_hit_rect() == Rect2(Vector2(590, 100), Vector2(45, 45)),
		"episode select keeps the original up-arrow hitbox"
	)
	_assert(
		EpisodeSelectScreenScript.down_arrow_hit_rect() == Rect2(Vector2(590, 350), Vector2(45, 45)),
		"episode select keeps the original down-arrow hitbox"
	)
	episode_select.call("reset_background_animation_for_test")
	var episode_background_offsets: Dictionary = episode_select.call("background_offsets")
	_assert(int(episode_background_offsets["primary"]) == 0 and int(episode_background_offsets["secondary"]) == 0, "episode select background starts at original zero offsets")
	episode_select.call("advance_background_animation", EpisodeSelectScreenScript.BACKGROUND_SCROLL_STEP_SECONDS)
	episode_background_offsets = episode_select.call("background_offsets")
	_assert(int(episode_background_offsets["primary"]) == 0 and int(episode_background_offsets["secondary"]) == 0, "episode select background waits for strict original 30 ms gate")
	episode_select.call("advance_background_animation", 0.001)
	episode_background_offsets = episode_select.call("background_offsets")
	_assert(int(episode_background_offsets["primary"]) == 1, "episode select primary background advances by original one-pixel step")
	_assert(int(episode_background_offsets["secondary"]) == 3, "episode select secondary background advances by original three-pixel step")
	_assert(EpisodeSelectScreenScript.primary_background_source_rect() == Rect2(Vector2(0, 0), Vector2(48, 48)), "episode select primary background uses the first original BgEpisode tile")
	_assert(EpisodeSelectScreenScript.secondary_background_source_rect() == Rect2(Vector2(48, 0), Vector2(48, 48)), "episode select secondary background uses the second original BgEpisode tile")
	_assert(EpisodeSelectScreenScript.primary_background_target_rect(Vector2.ZERO, 1) == Rect2(Vector2(-47, -47), Vector2(48, 48)), "episode select primary background scrolls diagonally like original")
	_assert(EpisodeSelectScreenScript.secondary_background_target_rect(Vector2.ZERO, 3) == Rect2(Vector2(-45, -45), Vector2(48, 48)), "episode select secondary background scrolls diagonally like original")
	for _background_wrap_index in range(int(EpisodeSelectScreenScript.BG_TILE_SIZE.x) - 1):
		episode_select.call("advance_background_animation", EpisodeSelectScreenScript.BACKGROUND_SCROLL_STEP_SECONDS + 0.001)
	episode_background_offsets = episode_select.call("background_offsets")
	_assert(int(episode_background_offsets["primary"]) == 0, "episode select primary background wraps at original 48px tile size")
	_assert(int(episode_background_offsets["secondary"]) == 0, "episode select secondary background wraps at original 48px tile size")
	var page_status_label = episode_select.find_child("PageStatus", true, false)
	var browser_title = episode_select.find_child("BrowserTitle", true, false)
	var title_header = episode_select.find_child("TitleHeader", true, false)
	var level_header = episode_select.find_child("LevelHeader", true, false)
	var first_row_title = episode_select.find_child("Title", true, false)
	_assert(page_status_label != null and page_status_label.get_script() == MenuBitmapLabelScript, "episode select renders page status with the original bitmap font")
	_assert(browser_title != null and browser_title.get_script() == MenuBitmapLabelScript and String(browser_title.text) == "Episode Browser. Select Episode.", "episode select renders original browser title")
	if browser_title != null:
		_assert(browser_title.position == Vector2(0, 13), "episode select places title at original y=13")
	_assert(title_header != null and title_header.get_script() == MenuBitmapLabelScript, "episode select renders headers with the original bitmap font")
	_assert(level_header != null and level_header.position == Vector2(535, 60), "episode select keeps the original right-aligned level column clear of the page arrows")
	_assert(first_row_title != null and first_row_title.get_script() == MenuBitmapLabelScript, "episode select renders row captions with the original bitmap font")
	var first_row_button_for_hitbox := episode_select.find_child("EpisodeRowButton1", true, false) as Button
	_assert(EpisodeSelectScreenScript.episode_row_hit_rect() == Rect2(Vector2(5, 100), Vector2(580, 330)), "episode select keeps original mouse row-selection bounds")
	if first_row_button_for_hitbox != null:
		_assert(first_row_button_for_hitbox.position == Vector2(5, 0), "episode select row hit area starts at original x=5")
		_assert(first_row_button_for_hitbox.focus_mode == Control.FOCUS_NONE, "episode select row hit areas disable native Godot focus highlights")
		_assert(first_row_button_for_hitbox.get_theme_stylebox("focus") is StyleBoxEmpty, "episode select row focus style is visually empty")

	var selected_summary: Dictionary = episode_select.call("selected_episode_summary")
	_assert(selected_summary.get("slug", "") == "Abstraction", "episode select defaults to first sorted episode")
	var selected_title_wave = episode_select.find_child("SelectedEpisodeTitleWave", true, false)
	_assert(selected_title_wave != null and selected_title_wave.get_script() == WaveBitmapLabelScript, "episode select renders selected episode name with original wave bitmap text")
	if selected_title_wave != null:
		_assert(String(selected_title_wave.get("text")) == "Abstraction", "episode select selected wave mirrors selected episode title")
		_assert(selected_title_wave.position == Vector2(55, 95), "episode select selected wave keeps original first-row baseline with 5px amplitude room")
	_assert(first_row_title == null or not first_row_title.visible, "episode select hides normal title text under selected wave row")
	episode_select.call("reset_selected_title_wave_for_test")
	episode_select.call("_process", EpisodeSelectScreenScript.SELECTED_TITLE_WAVE_STEP_SECONDS)
	_assert(is_equal_approx(float(episode_select.call("selected_title_wave_phase_degrees")), 0.0), "episode select selected title wave waits for original strict 40 ms gate")
	episode_select.call("_process", 0.001)
	_assert(is_equal_approx(float(episode_select.call("selected_title_wave_phase_degrees")), 20.0), "episode select selected title wave advances by original 20 degree step")
	if _audio != null and _audio.has_method("is_sfx_playing"):
		_assert(not bool(_audio.call("is_sfx_playing", "eff03")), "episode select startup stays silent")
		_assert(not bool(_audio.call("is_sfx_playing", "eff04")), "episode select initial focus stays silent")
	if _audio != null and _audio.has_method("stop_all"):
		_audio.call("stop_all")
	episode_select.call("_select_episode", 1)
	if selected_title_wave != null:
		_assert(String(selected_title_wave.get("text")) == "Alphabet", "episode select selected wave updates when row selection changes")
	if _audio != null and _audio.has_method("is_sfx_playing"):
		_assert(bool(_audio.call("is_sfx_playing", "eff04")), "episode select row change plays original hover cue")
		_audio.call("stop_all")
		episode_select.call("_select_episode", 1)
		_assert(not bool(_audio.call("is_sfx_playing", "eff04")), "episode select does not replay hover cue when selection is unchanged")

	episode_select.call("_set_down_arrow_hovered", true)
	episode_select.call("_process", EpisodeSelectScreenScript.ARROW_SELECTED_FRAME_GATE_SECONDS)
	_assert(int(episode_select.call("down_arrow_frame")) == 0, "episode select down arrow waits for the strict original 30 ms hover gate")
	episode_select.call("_process", 0.001)
	_assert(int(episode_select.call("down_arrow_frame")) == 1, "episode select down arrow advances after the original hover gate")
	episode_select.call("_set_down_arrow_hovered", false)
	_assert(int(episode_select.call("down_arrow_frame")) == 1, "episode select down arrow keeps its current frame when hover leaves")
	episode_select.call("_process", EpisodeSelectScreenScript.ARROW_RETURN_FRAME_GATE_SECONDS + 0.001)
	_assert(int(episode_select.call("down_arrow_frame")) == 2, "episode select down arrow continues its cycle after hover leaves")
	for _episode_arrow_finish_step in range(EpisodeSelectScreenScript.ARROW_FRAME_COUNT - 2):
		episode_select.call("_process", EpisodeSelectScreenScript.ARROW_RETURN_FRAME_GATE_SECONDS + 0.001)
	_assert(int(episode_select.call("down_arrow_frame")) == 0, "episode select down arrow stops after finishing its unhovered cycle")

	var down_button := episode_select.find_child("DownButton", true, false) as TextureButton
	if down_button != null:
		if _audio != null and _audio.has_method("stop_all"):
			_audio.call("stop_all")
		down_button.emit_signal("pressed")
		_assert(episode_select.call("current_page") == 1, "episode select down arrow advances page")
		_assert(episode_select.call("visible_row_count") == 7, "episode select second page shows remaining episodes")
		if _audio != null and _audio.has_method("is_sfx_playing"):
			_assert(bool(_audio.call("is_sfx_playing", "eff04")), "episode select page change plays hover cue when it lands on a new row")

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
		if _audio != null and _audio.has_method("stop_all"):
			_audio.call("stop_all")
		first_row_button.emit_signal("pressed")
		_assert(episode_signal_state["did_select_episode"], "episode row emits episode selected")
		_assert(not String(episode_signal_state["slug"]).is_empty(), "episode selection includes slug")
		_assert(episode_signal_state["level_number"] == 1, "episode selection starts at first level")
		if _audio != null and _audio.has_method("is_sfx_playing"):
			_assert(bool(_audio.call("is_sfx_playing", "eff03")), "episode activation plays original confirm cue")
	episode_select.queue_free()

	if _profile != null and _profile.has_method("set_save_path"):
		_profile.call("set_save_path", _test_profile_path("game_scene"), false)
	if _profile != null and _profile.has_method("record_score"):
		_assert(bool(_profile.call("record_score", 885)), "test profile accepts seeded high score")
	if _profile != null and _profile.has_method("set_bonus_stack_visible"):
		_profile.call("set_bonus_stack_visible", false)
		_profile.call("set_ball_tracks_visible", false)
		_profile.call("set_fps_visible", true)
		_profile.call("set_background_movable", false)
		_profile.call("set_background_type", 7)
	if _profile != null and _profile.has_method("set_music_enabled"):
		_profile.call("set_music_enabled", true)
		_profile.call("set_sfx_enabled", true)
		_profile.call("set_music_volume", 50)
		_profile.call("set_sfx_volume", 60)
		_profile.call("set_fullscreen_enabled", false)
	if _audio != null and _audio.has_method("apply_profile_settings"):
		_audio.call("apply_profile_settings")

	var game := GameScreenScene.instantiate()
	_assert(game.has_signal("game_over_confirmed"), "game screen exposes game-over confirmation signal")
	_assert(game.episode_slug == PlayfieldSpecScript.DEFAULT_EPISODE, "game screen defaults to shared episode")
	_assert(game.level_number == PlayfieldSpecScript.DEFAULT_LEVEL_NUMBER, "game screen defaults to shared level number")
	root.add_child(game)
	await process_frame
	_assert(bool(game.call("is_system_cursor_hidden")), "game screen reports hidden system cursor while active")
	_assert(bool(game.call("is_cursor_locked_to_game_map")), "game screen locks the cursor inside the gameplay viewport by default")
	_assert(not bool(game.call("is_cursor_released_from_game_map")), "game screen starts with released-cursor state disabled")

	var playfield := game.find_child("PlayfieldRenderer", true, false)
	_assert(playfield != null, "game screen creates playfield renderer")
	if playfield != null:
		_assert(playfield.default_episode == PlayfieldSpecScript.DEFAULT_EPISODE, "game screen configures playfield episode")
		_assert(playfield.default_level_number == PlayfieldSpecScript.DEFAULT_LEVEL_NUMBER, "game screen configures playfield level")
		_assert(playfield.level_data != null, "game screen loads default level data")
		_assert(playfield.board_state != null, "game screen creates mutable board state")
		var gameplay = game.call("current_game_session")
		_assert(gameplay != null, "game screen creates gameplay session")
		if gameplay != null:
			_assert(gameplay.board_state == playfield.board_state, "game screen shares gameplay board with renderer")
			_assert(gameplay.best_score == 885, "game screen starts run with persisted high score")
			_assert(game.find_child("RacketRenderer", true, false) != null, "game screen creates racket renderer")
			_assert(game.find_child("BallRenderer", true, false) != null, "game screen creates ball renderer")
			_assert(game.find_child("BonusRenderer", true, false) != null, "game screen creates bonus renderer")
			_assert(game.find_child("BulletRenderer", true, false) != null, "game screen creates bullet renderer")
			_assert(game.find_child("MonsterRenderer", true, false) != null, "game screen creates monster renderer")
			_assert(game.find_child("BeeRenderer", true, false) != null, "game screen creates bee renderer")
			_assert(game.find_child("SnakeRenderer", true, false) != null, "game screen creates snake VFX renderer")
			_assert(game.find_child("ImpactEffectRenderer", true, false) != null, "game screen creates impact effect renderer")
			_assert(game.find_child("ScorePopupRenderer", true, false) != null, "game screen creates score-popup renderer")
			_assert(game.find_child("LevelReadyRollerRenderer", true, false) != null, "game screen creates level-ready roller renderer")
			var snake_renderer_node := game.find_child("SnakeRenderer", true, false)
			var monster_renderer_node := game.find_child("MonsterRenderer", true, false)
			var bee_renderer_node := game.find_child("BeeRenderer", true, false)
			if snake_renderer_node != null and monster_renderer_node != null and bee_renderer_node != null:
				_assert(snake_renderer_node.get_index() < monster_renderer_node.get_index(), "game screen draws Snake VFX below registered monsters")
				_assert(monster_renderer_node.get_index() < bee_renderer_node.get_index(), "game screen keeps Bee hazard draw order above regular monsters")
			var impact_renderer_node := game.find_child("ImpactEffectRenderer", true, false)
			var score_popup_renderer_node := game.find_child("ScorePopupRenderer", true, false)
			var hud_renderer_node := game.find_child("GameHud", true, false)
			if impact_renderer_node != null and score_popup_renderer_node != null and hud_renderer_node != null:
				_assert(impact_renderer_node.get_index() < score_popup_renderer_node.get_index(), "game screen draws score popups above impact effects")
				_assert(score_popup_renderer_node.get_index() < hud_renderer_node.get_index(), "game screen keeps HUD above score popups")
			_assert(game.call("is_bonus_stack_visible") == false, "game screen loads bonus-stack visibility setting")
			_assert(game.call("are_ball_tracks_visible") == false, "game screen loads ball-track visibility setting")
			_assert(not gameplay.are_ball_tracks_enabled(), "game screen applies loaded ball-track visibility to gameplay generation")
			_assert(game.call("is_fps_visible"), "game screen loads FPS visibility setting")
			_assert(game.call("current_background_type") == 7, "game screen loads full-range background type setting")
			_assert(game.call("is_background_movable") == false, "game screen loads background movable setting")
			_assert(gameplay.is_level_ready_sequence_active(), "game screen starts level-ready sequence when board is loaded")
			var startup_indicators: Array[Dictionary] = gameplay.active_bonus_indicators()
			_assert(not startup_indicators.is_empty() and int(startup_indicators[0]["icon_index"]) == GameSessionScript.LEVEL_READY_STATUS_ICON_INDEX, "game screen exposes level-start countdown indicator")
			if _audio != null and _audio.has_method("play_sfx") and _audio.has_method("is_sfx_playing"):
				_audio.call("set_sfx_enabled", true)
				_audio.call("set_sfx_volume", 65)
				_assert(bool(_audio.call("play_sfx", "EffBee")), "game screen test can start bee SFX")
				_assert(bool(_audio.call("is_sfx_playing", "EffBee")), "bee SFX is active before routed stop event")
				gameplay.call("_queue_audio_event", GameSessionScript.SFX_EVENT_BEE_STOP)
				game.call("_play_pending_audio_events")
				_assert(not bool(_audio.call("is_sfx_playing", "EffBee")), "game screen routes bee-stop events to stop EffBee")
				if _audio.has_method("last_sfx_pan100_for_name"):
					gameplay.call("_queue_audio_event_at_x", GameSessionScript.SFX_EVENT_RACKET_BOUNCE, 0.0)
					game.call("_play_pending_audio_events")
					_assert(is_equal_approx(float(_audio.call("last_sfx_pan100_for_name", "eff07")), -100.0), "game screen drains positioned gameplay SFX payloads")
			var game_bonus_renderer := game.find_child("BonusRenderer", true, false)
			if game_bonus_renderer != null:
				_assert(not game_bonus_renderer.call("is_stack_visible"), "bonus renderer applies hidden stack setting")
			var game_ball_renderer := game.find_child("BallRenderer", true, false)
			if game_ball_renderer != null:
				_assert(not game_ball_renderer.call("are_tracks_visible"), "ball renderer applies hidden tracks setting")
			_assert(playfield.background_type == 7, "playfield applies loaded full-range background type")
			_assert(not playfield.call("is_background_movable"), "playfield applies loaded background movable setting")
			var fps_overlay := game.find_child("FpsOverlay", true, false) as Label
			_assert(fps_overlay != null and fps_overlay.visible, "game screen shows FPS overlay when enabled")
			var hud = game.call("current_hud")
			_assert(hud != null, "game screen creates gameplay hud")
			if hud != null:
				var hud_values: Dictionary = hud.call("status_values")
				_assert(hud_values["score"] == 0, "game hud starts with score")
				_assert(hud_values["lives"] == GameSessionScript.INITIAL_LIVES, "game hud starts with spare balls")
				_assert(hud_values["level"] == PlayfieldSpecScript.DEFAULT_LEVEL_NUMBER, "game hud starts with display level")
				_assert(hud_values["best_score"] == 885, "game hud starts with persisted high score")
				var game_hud_bitmap_status: Dictionary = hud.call("bitmap_text_status")
				_assert(game_hud_bitmap_status["statistic_texture"], "game screen hud loads Statistic header strip")
				_assert(game_hud_bitmap_status["font_text"], "game screen hud binds original Font renderer for header values")
				_assert(game_hud_bitmap_status["digit_text"], "game screen hud binds original Digits renderer for timed status values")
				var startup_ready_prompt: Dictionary = hud.call("ready_prompt_layout")
				_assert(bool(startup_ready_prompt["visible"]), "game screen hud shows ready prompt at level start")
				_assert(startup_ready_prompt["ready_text"] == "Get Ready!", "game screen hud uses original get-ready prompt")
				_assert(startup_ready_prompt["level_text"] == "Level #1", "game screen hud shows current level in ready prompt")
				_assert(startup_ready_prompt["hint_text"] == "(Press Mouse Button when ready)", "game screen hud uses original launch hint")
				var startup_roller_layout: Dictionary = gameplay.level_ready_roller_layout()
				_assert(bool(startup_roller_layout["visible"]), "game screen exposes original level-ready roller at startup")
				_assert(startup_roller_layout["destination"] == Rect2(Vector2(47, 63), Vector2(20, 390)), "game screen starts level-ready roller at original board edge")
				_assert(playfield.call("current_level_reveal_offset_pixels") == 0.0, "game screen initially hides bricks to the right of the ready roller")
				game.call("_process", GameSessionScript.LEVEL_READY_ROLLER_STEP_SECONDS)
				_assert(playfield.call("current_level_reveal_offset_pixels") == GameSessionScript.LEVEL_READY_ROLLER_STEP_PIXELS, "game screen advances the brick reveal with the roller")
				game.call("_input", _action_event(GameScreenScript.ACTION_LAUNCH_BALL))
				await process_frame
				_assert(gameplay.state == GameSessionScript.STATE_READY, "game screen launch during get-ready only skips the animation")
				_assert(not gameplay.is_level_ready_prompt_visible(), "game screen launch during get-ready hides the roller")
				_assert(playfield.call("current_level_reveal_offset_pixels") == -1.0, "game screen launch during get-ready restores the full brick map")
				game.call("_process", GameSessionScript.LEVEL_READY_ANIMATION_SECONDS)
				var finished_startup_prompt: Dictionary = hud.call("ready_prompt_layout")
				_assert(not bool(finished_startup_prompt.get("visible", false)), "game screen hud hides ready prompt when the startup animation finishes")
				_assert(not bool(gameplay.level_ready_roller_layout().get("visible", false)), "game screen hides level-ready roller when it reaches the right side")
				_assert(playfield.call("current_level_reveal_offset_pixels") == -1.0, "game screen restores the full brick map after the roller finishes")
				_assert(gameplay.state == GameSessionScript.STATE_READY, "game screen stays ready to launch after get-ready labels disappear")
			gameplay.award_score(1000)
			game.call("_process", 0.0)
			if _profile != null and _profile.has_method("best_score"):
				_assert(int(_profile.call("best_score")) == 1000, "game screen records new persisted high score")
			game.call("move_racket_to", 10000.0)
			_assert(gameplay.racket_rect().end.y == GameSessionScript.RACKET_MAX_BOTTOM, "game screen routes racket movement")
			game.call("_input", _action_event(GameScreenScript.ACTION_LAUNCH_BALL))
			await process_frame
			_assert(gameplay.state == GameSessionScript.STATE_PLAYING, "game screen launch enters playing state")
			_assert(not gameplay.is_level_ready_sequence_active(), "game screen launch clears level-ready sequence")
			_stack_bonus(gameplay, GameSessionScript.BONUS_EXTRA_LIFE)
			game.call("_input", _action_event(GameScreenScript.ACTION_USE_BONUS))
			await process_frame
			_assert(gameplay.lives_remaining == GameSessionScript.INITIAL_LIVES + 1, "game screen routes use-bonus action to bonus activation")
			game.call("_input", _action_event(GameScreenScript.ACTION_DEBUG_CHEATS))
			await process_frame
			_assert(game.call("is_debug_cheats_visible"), "debug-cheats action opens the debug stack window")
			_assert(game.call("is_game_paused"), "debug stack window pauses gameplay")
			_assert(not bool(game.call("is_system_cursor_hidden")), "debug stack window shows the system cursor for UI controls")
			game.call("set_music_volume", 70)
			game.call("_input", _key_event(KEY_MINUS, 45))
			await process_frame
			_assert(int(game.call("music_volume")) == 70, "debug cheats modal focus blocks runtime volume shortcuts")
			var debug_overlay := game.call("current_debug_cheats_overlay") as Control
			_assert(debug_overlay != null and debug_overlay.visible, "game screen creates the debug cheats overlay")
			if debug_overlay != null:
				var debug_add_button := debug_overlay.find_child("AddBonus%d" % GameSessionScript.BONUS_EXTRA_LIFE, true, false) as Button
				_assert(debug_add_button != null and not debug_add_button.disabled, "debug cheats overlay exposes add buttons")
				if debug_add_button != null:
					debug_add_button.emit_signal("pressed")
					await process_frame
					_assert(gameplay.bonus_stack_entries().size() == 1, "debug cheats add button appends to stack")
					_assert(int(gameplay.bonus_stack_entries()[0]["type_id"]) == GameSessionScript.BONUS_EXTRA_LIFE, "debug cheats add button preserves item type")
				var debug_remove_button := debug_overlay.find_child("RemoveStackEntry0", true, false) as Button
				_assert(debug_remove_button != null, "debug cheats overlay exposes remove buttons")
				if debug_remove_button != null:
					debug_remove_button.emit_signal("pressed")
					await process_frame
					_assert(gameplay.bonus_stack_entries().is_empty(), "debug cheats remove button deletes selected stack item")
				for debug_stack_type in [GameSessionScript.BONUS_ADD_FIREBALL, GameSessionScript.BONUS_JUMP_TO_NEXT_LEVEL]:
					gameplay.debug_add_bonus_to_stack(debug_stack_type)
				debug_overlay.call("refresh")
				var debug_clear_button := debug_overlay.find_child("ClearStackButton", true, false) as Button
				_assert(debug_clear_button != null and not debug_clear_button.disabled, "debug cheats overlay exposes clear-stack button")
				if debug_clear_button != null:
					debug_clear_button.emit_signal("pressed")
					await process_frame
					_assert(gameplay.bonus_stack_entries().is_empty(), "debug cheats clear button empties stack")
				var debug_snake_button := debug_overlay.find_child("SpawnSnakeVfxButton", true, false) as Button
				_assert(debug_snake_button != null, "debug cheats overlay exposes Snake VFX preview button")
				if debug_snake_button != null:
					gameplay.pop_audio_events()
					debug_snake_button.emit_signal("pressed")
					await process_frame
					_assert(gameplay.active_snake_segment_count() == 8, "debug Snake VFX button spawns the bounded preview chain")
					_assert(gameplay.pop_audio_events().is_empty(), "debug Snake VFX button stays silent without original SFX evidence")
					gameplay.debug_clear_snake_vfx_preview()
					_assert(gameplay.active_snake_segment_count() == 0, "debug Snake VFX clear helper removes preview chain after UI spawn")
				for full_debug_index in range(GameSessionScript.MAX_STACKED_BONUSES):
					gameplay.debug_add_bonus_to_stack(full_debug_index % GameSessionScript.BONUS_TYPE_COUNT)
				debug_overlay.call("refresh")
				var disabled_add_button := debug_overlay.find_child("AddBonus%d" % GameSessionScript.BONUS_EXTRA_LIFE, true, false) as Button
				_assert(disabled_add_button != null and disabled_add_button.disabled, "debug cheats overlay disables add buttons when stack is full")
				gameplay.bonus_stack.clear()
			game.call("_input", _action_event(GameScreenScript.ACTION_TERMINATE_GAME))
			await process_frame
			_assert(not game.call("is_debug_cheats_visible"), "Escape closes the debug stack window first")
			_assert(not game.call("is_exit_confirmation_visible"), "Escape does not open leave-board confirmation while closing debug cheats")
			_assert(not game.call("is_game_paused"), "closing debug cheats restores active gameplay")
			game.call("_input", _action_event(GameScreenScript.ACTION_TOGGLE_BONUS_STACK))
			await process_frame
			_assert(game.call("is_bonus_stack_visible"), "game screen routes bonus-stack toggle")
			if _profile != null and _profile.has_method("bonus_stack_visible"):
				_assert(bool(_profile.call("bonus_stack_visible")), "bonus-stack toggle persists to profile")
			game.call("_input", _action_event(GameScreenScript.ACTION_TOGGLE_BALL_TRACKS))
			await process_frame
			_assert(game.call("are_ball_tracks_visible"), "game screen routes ball-track toggle")
			_assert(gameplay.are_ball_tracks_enabled(), "ball-track action reenables gameplay track generation")
			if game_ball_renderer != null:
				_assert(game_ball_renderer.call("are_tracks_visible"), "ball-track action reenables renderer tracks")
			game.call("_input", _action_event(GameScreenScript.ACTION_TOGGLE_FPS))
			await process_frame
			_assert(not game.call("is_fps_visible"), "game screen routes FPS toggle")
			game.call("_input", _action_event(GameScreenScript.ACTION_TOGGLE_MUSIC))
			await process_frame
			_assert(not bool(game.call("is_music_enabled")), "game screen routes F7 music toggle")
			if _profile != null and _profile.has_method("music_enabled"):
				_assert(not bool(_profile.call("music_enabled")), "game screen persists F7 music toggle")
			if _audio != null and _audio.has_method("music_enabled"):
				_assert(not bool(_audio.call("music_enabled")), "game screen syncs F7 music toggle to audio")
			game.call("_input", _action_event(GameScreenScript.ACTION_TOGGLE_MUSIC))
			await process_frame
			_assert(bool(game.call("is_music_enabled")), "game screen routes second F7 music toggle")
			game.call("_input", _action_event(GameScreenScript.ACTION_TOGGLE_SFX))
			await process_frame
			_assert(not bool(game.call("is_sfx_enabled")), "game screen routes F8 SFX toggle")
			if _profile != null and _profile.has_method("sfx_enabled"):
				_assert(not bool(_profile.call("sfx_enabled")), "game screen persists F8 SFX toggle")
			if _audio != null and _audio.has_method("sfx_enabled"):
				_assert(not bool(_audio.call("sfx_enabled")), "game screen syncs F8 SFX toggle to audio")
			game.call("_input", _action_event(GameScreenScript.ACTION_TOGGLE_SFX))
			await process_frame
			_assert(bool(game.call("is_sfx_enabled")), "game screen routes second F8 SFX toggle")
			game.call("set_music_volume", 50)
			game.call("_input", _key_event(KEY_KP_ADD))
			await process_frame
			_assert(int(game.call("music_volume")) == 51, "game screen routes plus to music volume increase")
			game.call("_input", _key_event(KEY_MINUS, 45))
			await process_frame
			_assert(int(game.call("music_volume")) == 50, "game screen routes minus to music volume decrease")
			game.call("set_sfx_volume", 60)
			game.call("_input", _key_event(KEY_EQUAL, 43, true))
			await process_frame
			_assert(int(game.call("sfx_volume")) == 61, "game screen routes Shift+plus to SFX volume increase")
			game.call("_input", _key_event(KEY_MINUS, 95, true))
			await process_frame
			_assert(int(game.call("sfx_volume")) == 60, "game screen routes Shift+minus to SFX volume decrease")
			game.call("set_music_volume", 100)
			game.call("_input", _key_event(KEY_KP_ADD))
			await process_frame
			_assert(int(game.call("music_volume")) == 100, "game screen clamps music volume shortcut at maximum")
			game.call("set_sfx_volume", 0)
			game.call("_input", _key_event(KEY_KP_SUBTRACT, 0, true))
			await process_frame
			_assert(int(game.call("sfx_volume")) == 0, "game screen clamps SFX volume shortcut at minimum")
			game.call("_input", _action_event(GameScreenScript.ACTION_RELEASE_CURSOR))
			await process_frame
			_assert(bool(game.call("is_cursor_released_from_game_map")), "game screen releases the cursor on Ctrl+U")
			_assert(not bool(game.call("is_system_cursor_hidden")), "released gameplay cursor shows the system cursor")
			_assert(not bool(game.call("is_cursor_locked_to_game_map")), "released gameplay cursor no longer stays confined to the viewport")
			game.call("_input", _mouse_button_event(MOUSE_BUTTON_LEFT))
			await process_frame
			_assert(not bool(game.call("is_cursor_released_from_game_map")), "gameplay mouse click relocks a released cursor")
			_assert(bool(game.call("is_cursor_locked_to_game_map")), "gameplay mouse click restores viewport-locked cursor state")
			game.call("_input", _action_event(GameScreenScript.ACTION_CYCLE_BACKGROUND))
			await process_frame
			_assert(game.call("current_background_type") == 0, "game screen wraps background-cycle action across all original background types")
			_assert(playfield.background_type == 0, "background-cycle action updates the playfield with wrapped background type")
			game.call("_input", _action_event(GameScreenScript.ACTION_TOGGLE_BACKGROUND_MOTION))
			await process_frame
			_assert(game.call("is_background_movable"), "game screen routes Shift+G to background motion toggle")
			_assert(playfield.call("is_background_movable"), "background motion toggle updates the playfield")
			if _profile != null and _profile.has_method("background_movable"):
				_assert(bool(_profile.call("background_movable")), "background motion toggle persists to profile")
			var background_type_before_motion_toggle := int(game.call("current_background_type"))
			game.call("_input", _action_event(GameScreenScript.ACTION_TOGGLE_BACKGROUND_MOTION))
			await process_frame
			_assert(not game.call("is_background_movable"), "game screen routes second Shift+G to disable background motion")
			_assert(int(game.call("current_background_type")) == background_type_before_motion_toggle, "Shift+G leaves background type unchanged")
			game.call("_input", _action_event(GameScreenScript.ACTION_TOGGLE_FULLSCREEN))
			await process_frame
			if _profile != null and _profile.has_method("fullscreen_enabled"):
				_assert(bool(_profile.call("fullscreen_enabled")), "game screen routes Alt+Enter to persisted fullscreen toggle")
			game.call("_input", _action_event(GameScreenScript.ACTION_TOGGLE_FULLSCREEN))
			await process_frame
			if _profile != null and _profile.has_method("fullscreen_enabled"):
				_assert(not bool(_profile.call("fullscreen_enabled")), "game screen routes second Alt+Enter to windowed mode")
			game.call("_input", _action_event(GameScreenScript.ACTION_PAUSE))
			await process_frame
			_assert(game.call("is_game_paused"), "game screen routes pause action")
			game.call("set_music_volume", 80)
			game.call("_input", _key_event(KEY_MINUS, 45))
			await process_frame
			_assert(int(game.call("music_volume")) == 79, "game screen runtime shortcuts remain active while paused")
			_assert(bool(game.call("is_system_cursor_hidden")), "pause keeps the system cursor hidden behind the original hourglass")
			var hourglass_cursor := game.find_child("HourglassCursorOverlay", true, false)
			_assert(hourglass_cursor != null and bool(hourglass_cursor.call("is_cursor_visible")), "game screen shows original hourglass cursor on pause")
			if hourglass_cursor != null:
				var paused_ball_position: Vector2 = gameplay.call("first_ball_position")
				var hourglass_frame := int(hourglass_cursor.call("current_frame_index"))
				game.call("_process", 0.12)
				_assert(gameplay.call("first_ball_position") == paused_ball_position, "pause freezes gameplay movement")
				_assert(int(hourglass_cursor.call("current_frame_index")) != hourglass_frame, "pause hourglass cursor animates")
			game.call("_input", _action_event(GameScreenScript.ACTION_DEBUG_CHEATS))
			await process_frame
			_assert(game.call("is_debug_cheats_visible"), "debug cheats can open while the game is already paused")
			_assert(game.call("is_game_paused"), "debug cheats keeps existing pause state")
			if hourglass_cursor != null:
				_assert(not bool(hourglass_cursor.call("is_cursor_visible")), "debug cheats hides the pause hourglass while interactive")
			game.call("_input", _action_event(GameScreenScript.ACTION_DEBUG_CHEATS))
			await process_frame
			_assert(not game.call("is_debug_cheats_visible"), "debug-cheats action closes the debug window")
			_assert(game.call("is_game_paused"), "closing debug cheats restores the previous paused state")
			if hourglass_cursor != null:
				_assert(bool(hourglass_cursor.call("is_cursor_visible")), "pause hourglass returns after closing debug cheats from pause")
			game.call("_input", _action_event(GameScreenScript.ACTION_TERMINATE_GAME))
			await process_frame
			_assert(game.call("is_exit_confirmation_visible"), "Escape opens leave-board confirmation while paused")
			game.call("set_music_volume", 70)
			game.call("_input", _key_event(KEY_MINUS, 45))
			await process_frame
			_assert(int(game.call("music_volume")) == 70, "leave-board confirmation blocks runtime volume shortcuts")
			_assert(game.find_child("ExitConfirmationPrompt", true, false) == null, "game screen no longer creates a native leave-board prompt label")
			if hud != null:
				var confirmation_layout: Dictionary = hud.call("exit_confirmation_layout")
				_assert(bool(confirmation_layout["visible"]), "game screen shows leave-board prompt through the bitmap hud")
				_assert(confirmation_layout["title_text"] == "Are You sure to leave", "leave-board prompt uses original first line")
				_assert(confirmation_layout["summary_text"] == "this board (Y / N)", "leave-board prompt uses original second line")
			game.call("_input", _action_event(GameScreenScript.ACTION_PAUSE))
			await process_frame
			_assert(game.call("is_game_paused"), "pause toggle is ignored while leave-board confirmation is visible")
			game.call("_input", _key_event(KEY_N, 110))
			await process_frame
			_assert(not game.call("is_exit_confirmation_visible"), "N cancels leave-board confirmation")
			_assert(game.call("is_game_paused"), "canceling leave-board confirmation restores paused state")
			if hourglass_cursor != null:
				_assert(bool(hourglass_cursor.call("is_cursor_visible")), "paused hourglass remains visible after canceled leave-board confirmation")
			game.call("_input", _action_event(GameScreenScript.ACTION_PAUSE))
			await process_frame
			_assert(not game.call("is_game_paused"), "game screen routes pause resume action")
			game.call("_input", _action_event(GameScreenScript.ACTION_TERMINATE_GAME))
			await process_frame
			_assert(game.call("is_exit_confirmation_visible"), "Escape opens leave-board confirmation while playing")
			_stack_bonus(gameplay, GameSessionScript.BONUS_EXTRA_LIFE)
			var lives_before_confirm_input := int(gameplay.lives_remaining)
			game.call("_input", _action_event(GameScreenScript.ACTION_USE_BONUS))
			await process_frame
			_assert(gameplay.lives_remaining == lives_before_confirm_input, "leave-board confirmation blocks gameplay input")
			gameplay.bonus_stack.clear()
			game.call("_input", _key_event(KEY_N, 110))
			await process_frame
			_assert(not game.call("is_exit_confirmation_visible"), "N cancels playing leave-board confirmation")
			var direct_exit_signal_state := {
				"confirmed": false,
				"score": 0,
				"level": 0,
				"episode": "",
			}
			game.game_over_confirmed.connect(func(score: int, level_number: int, confirmed_episode: String) -> void:
				direct_exit_signal_state["confirmed"] = true
				direct_exit_signal_state["score"] = score
				direct_exit_signal_state["level"] = level_number
				direct_exit_signal_state["episode"] = confirmed_episode
			)
			game.call("_input", _action_event(GameScreenScript.ACTION_TERMINATE_GAME))
			await process_frame
			game.call("_input", _key_event(KEY_Y, 121))
			await process_frame
			_assert(not direct_exit_signal_state["confirmed"], "Y confirms leave-board route into game-over summary before score confirmation")
			_assert(gameplay.state == GameSessionScript.STATE_GAME_OVER, "confirmed leave-board route enters game-over summary state")
			if hud != null:
				hud.call("refresh")
				var exit_game_over_layout: Dictionary = hud.call("game_over_layout")
				_assert(bool(exit_game_over_layout["visible"]), "confirmed leave-board route shows game-over title before name entry")
				_assert(exit_game_over_layout["summary_text"] == "Your Level #%d, and Score %d" % [int(gameplay.display_level_number), int(gameplay.score)], "confirmed leave-board route shows game-over summary before name entry")
			game.call("_input", _action_event(GameScreenScript.ACTION_LAUNCH_BALL))
			await process_frame
			_assert(direct_exit_signal_state["confirmed"], "mouse confirms leave-board game-over summary into score confirmation")
			_assert(direct_exit_signal_state["score"] == int(gameplay.score), "leave-board confirmation carries current score")
			_assert(direct_exit_signal_state["level"] == int(gameplay.display_level_number), "leave-board confirmation carries current level")
			_assert(direct_exit_signal_state["episode"] == game.episode_slug, "leave-board confirmation carries current episode")
			gameplay.state = GameSessionScript.STATE_PLAYING
			_stack_bonus(gameplay, GameSessionScript.BONUS_BACK_WALL)
			game.call("activate_next_bonus")
			await process_frame
			_assert(playfield.call("is_back_wall_active"), "game screen syncs back-wall visual state")
			_stack_bonus(gameplay, GameSessionScript.BONUS_SHOOTING_PADDLE_TIMED)
			var shooting_result: Dictionary = game.call("activate_next_bonus")
			await process_frame
			_assert(shooting_result["effect"] == "shooting_paddle_one_shot", "game screen routes shooting bonus activation")
			_assert(gameplay.active_projectile_count() == 0, "game screen leaves shooting bonus armed until right-click fire")
			game.call("_input", _action_event(GameScreenScript.ACTION_FIRE_PADDLE))
			await process_frame
			_assert(gameplay.active_projectile_count() == 1, "game screen routes right-click shooting-paddle fire")
			gameplay.projectiles.clear()
			_stack_bonus(gameplay, GameSessionScript.BONUS_SHOOTING_PADDLE_CONTINUOUS)
			var continuous_shooting_result: Dictionary = game.call("activate_next_bonus")
			await process_frame
			_assert(continuous_shooting_result["effect"] == "shooting_paddle_continuous", "game screen routes continuous shooting bonus activation")
			gameplay._projectile_fire_cooldown = 0.0
			Input.action_press(GameScreenScript.ACTION_FIRE_PADDLE)
			game.call("_process", 0.0)
			_assert(gameplay.active_projectile_count() == 1, "held fire shoots continuous launcher immediately")
			game.call("_process", GameSessionScript.PROJECTILE_FIRE_COOLDOWN_SECONDS)
			Input.action_release(GameScreenScript.ACTION_FIRE_PADDLE)
			_assert(gameplay.active_projectile_count() == 2, "held fire auto-shoots continuous launcher after cooldown")
			if hud != null:
				gameplay.state = GameSessionScript.STATE_GAME_OVER
				gameplay.lives_remaining = -1
				gameplay.score = 45
				gameplay.display_level_number = 3
				hud.call("refresh")
				var direct_game_over_layout: Dictionary = hud.call("game_over_layout")
				_assert(bool(direct_game_over_layout["visible"]), "game hud shows game over title")
				_assert(direct_game_over_layout["summary_text"] == "Your Level #3, and Score 45", "game hud shows game over run summary")
	game.queue_free()
	await process_frame
	_assert(Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE, "leaving the game map restores the system cursor")

	if _profile != null and _profile.has_method("set_music_enabled"):
		_profile.call("set_music_enabled", false)
	if _audio != null and _audio.has_method("apply_profile_settings"):
		_audio.call("apply_profile_settings")

	var app := AppScene.instantiate()
	root.add_child(app)
	await process_frame
	_assert_app_original_cursor(app, "app starts menu screens with the original cursor overlay")
	_assert_app_original_cursor_animation(app, "app animates the original cursor logo overlay")
	_assert(not bool(app.call("is_fullscreen_enabled")), "app starts in windowed mode from the persisted profile")
	_assert(bool(app.call("toggle_fullscreen_enabled")), "app shell exposes persisted fullscreen toggling")
	if _profile != null and _profile.has_method("fullscreen_enabled"):
		_assert(bool(_profile.call("fullscreen_enabled")), "app fullscreen toggle persists enabled state")
	_assert(not bool(app.call("toggle_fullscreen_enabled")), "app shell can toggle fullscreen back to windowed")
	if _profile != null and _profile.has_method("fullscreen_enabled"):
		_assert(not bool(_profile.call("fullscreen_enabled")), "app fullscreen toggle persists disabled state")

	var app_menu := app.find_child("MainMenuScreen", true, false)
	_assert(app_menu != null, "app starts on main menu screen")
	if _audio != null and _audio.has_method("current_music_context"):
		_assert(String(_audio.call("current_music_context")) == AudioCueCatalogScript.CONTEXT_MAIN_MENU, "app starts main-menu music context")
		_assert(String(_audio.call("current_music_name")) == "Abnormal", "app starts original main-menu music")

	if app_menu != null:
		app_menu.emit_signal("quit_requested")
		await process_frame
		var app_exit_confirm := app.find_child("ExitConfirmScreen", true, false)
		_assert(app_exit_confirm != null, "app routes main-menu Exit into the original exit confirmation screen")
		_assert_app_original_cursor(app, "exit confirmation screen keeps the original cursor overlay")
		if _audio != null and _audio.has_method("current_music_context"):
			_assert(String(_audio.call("current_music_context")) == AudioCueCatalogScript.CONTEXT_MAIN_MENU, "exit confirmation keeps main-menu music context")
			_assert(String(_audio.call("current_music_name")) == "Abnormal", "exit confirmation keeps original main-menu music")
		if app_exit_confirm != null:
			app_exit_confirm.emit_signal("back_requested")
			await process_frame
		app_menu = app.find_child("MainMenuScreen", true, false)
		_assert(app_menu != null, "exit confirmation Backward returns to main menu")
		_assert_app_original_cursor(app, "exit confirmation back restores the original cursor overlay")

	if app_menu != null:
		app_menu.emit_signal("rules_requested")
		await process_frame
		var app_rules := app.find_child("RulesScreen", true, false)
		_assert(app_rules != null, "app switches from menu to rules screen")
		_assert_app_original_cursor(app, "rules screen keeps the original cursor overlay")
		if _audio != null and _audio.has_method("current_music_context"):
			_assert(String(_audio.call("current_music_context")) == AudioCueCatalogScript.CONTEXT_RULES, "rules screen uses rules music context")
			_assert(String(_audio.call("current_music_name")) == "Abnormal", "rules screen keeps original main-menu music")
		if app_rules != null:
			app_rules.emit_signal("back_requested")
			await process_frame
		app_menu = app.find_child("MainMenuScreen", true, false)
		_assert(app_menu != null, "app returns from rules screen to main menu")
		_assert_app_original_cursor(app, "rules back restores the original cursor overlay")
		if _audio != null and _audio.has_method("current_music_context"):
			_assert(String(_audio.call("current_music_context")) == AudioCueCatalogScript.CONTEXT_MAIN_MENU, "rules back restores main-menu music context")

	if app_menu != null:
		app_menu.emit_signal("high_score_requested")
		await process_frame
		var app_high_score := app.find_child("HighScoreScreen", true, false)
		_assert(app_high_score != null, "app switches from menu to high-score screen")
		_assert_app_original_cursor(app, "high-score screen keeps the original cursor overlay")
		if _audio != null and _audio.has_method("current_music_context"):
			_assert(String(_audio.call("current_music_context")) == AudioCueCatalogScript.CONTEXT_HIGH_SCORE, "high-score screen uses high-score music context")
			_assert(String(_audio.call("current_music_name")) == "theme2", "high-score screen uses original theme2 music")
		if app_high_score != null:
			app_high_score.emit_signal("back_requested")
			await process_frame
		app_menu = app.find_child("MainMenuScreen", true, false)
		_assert(app_menu != null, "app returns from high-score screen to main menu")
		_assert_app_original_cursor(app, "high-score back restores the original cursor overlay")

	if app_menu != null:
		app_menu.emit_signal("options_requested")
		await process_frame
		var app_options := app.find_child("OptionsScreen", true, false)
		_assert(app_options != null, "app switches from menu to options screen")
		_assert_app_original_cursor(app, "options screen keeps the original cursor overlay")
		if _audio != null and _audio.has_method("current_music_context"):
			_assert(String(_audio.call("current_music_context")) == AudioCueCatalogScript.CONTEXT_OPTIONS, "options screen uses options music context")
			_assert(String(_audio.call("current_music_name")) == "Abnormal", "options screen keeps original main-menu music")
		if app_options != null:
			app_options.call("set_fullscreen_enabled", true)
			await process_frame
			_assert(bool(app.call("is_fullscreen_enabled")), "options screen applies fullscreen changes through the app shell")
			app_options.call("set_fullscreen_enabled", false)
			await process_frame
			_assert(not bool(app.call("is_fullscreen_enabled")), "options screen can return the app shell to windowed mode")
			app_options.emit_signal("back_requested")
			await process_frame
		app_menu = app.find_child("MainMenuScreen", true, false)
		_assert(app_menu != null, "app returns from options screen to main menu")
		_assert_app_original_cursor(app, "options back restores the original cursor overlay")

	if app_menu != null:
		app_menu.emit_signal("credits_requested")
		await process_frame
		var app_credits := app.find_child("CreditsScreen", true, false)
		_assert(app_credits != null, "app switches from menu to credits screen")
		_assert_app_original_cursor(app, "credits screen keeps the original cursor overlay")
		if _audio != null and _audio.has_method("current_music_context"):
			_assert(String(_audio.call("current_music_context")) == AudioCueCatalogScript.CONTEXT_CREDITS, "credits screen uses credits music context")
			_assert(String(_audio.call("current_music_name")) == "theme5", "credits screen uses original theme5 music")
		if app_credits != null:
			app_credits.emit_signal("back_requested")
			await process_frame
		app_menu = app.find_child("MainMenuScreen", true, false)
		_assert(app_menu != null, "app returns from credits screen to main menu")
		_assert_app_original_cursor(app, "credits back restores the original cursor overlay")

	if app_menu != null:
		app_menu.emit_signal("start_game_requested")
		await process_frame
		var app_episode_select := app.find_child("EpisodeSelectScreen", true, false)
		_assert(app_episode_select != null, "app switches from menu to episode select screen")
		_assert_app_original_cursor(app, "episode select keeps the original cursor overlay")
		if _audio != null and _audio.has_method("current_music_context"):
			_assert(String(_audio.call("current_music_context")) == AudioCueCatalogScript.CONTEXT_EPISODE_SELECT, "episode select uses episode-select music context")
			_assert(String(_audio.call("current_music_name")) == "theme1", "episode select uses original theme1 music")
		if app_episode_select != null:
			app_episode_select.emit_signal("episode_selected", "Retro", 1)
			await process_frame
			var app_game := app.find_child("GameScreen", true, false)
			_assert(app_game != null, "app switches from episode select to game screen")
			_assert(app_game != null and bool(app_game.call("is_system_cursor_hidden")), "app hides the system cursor after entering gameplay")
			_assert_app_original_cursor_inactive(app, "game screen disables the menu cursor overlay")
			if _audio != null and _audio.has_method("current_music_context"):
				_assert(String(_audio.call("current_music_context")) == AudioCueCatalogScript.CONTEXT_GAMEPLAY, "game screen uses gameplay music context")
				_assert(String(_audio.call("current_music_name")) == "theme4", "game screen uses original theme4 music")
			if app_game != null:
				_assert(app_game.episode_slug == "Retro", "app starts selected episode")
				_assert(app_game.level_number == 1, "app starts selected episode at first level")
				var app_gameplay = app_game.call("current_game_session")
				if app_gameplay != null:
					app_gameplay.state = GameSessionScript.STATE_GAME_OVER
					app_gameplay.score = 1200
					app_gameplay.display_level_number = 4
					app_game.call("_input", _action_event(GameScreenScript.ACTION_LAUNCH_BALL))
					await process_frame
					var app_name_entry := app.find_child("NameEntryScreen", true, false)
					_assert(app_name_entry != null, "app routes qualifying game-over score to name entry")
					_assert_app_no_mouse_cursor(app, "app hides every mouse cursor for name entry")
					if _audio != null and _audio.has_method("current_music_context"):
						_assert(String(_audio.call("current_music_context")) == AudioCueCatalogScript.CONTEXT_NAME_ENTRY, "name entry uses name-entry music context")
						_assert(String(_audio.call("current_music_name")) == "theme3", "name entry uses original theme3 music")
					if app_name_entry != null:
						app_name_entry.call("set_player_name", "Ada")
						app_name_entry.call("submit_name")
						await process_frame
						var submitted_entries: Array = _profile.call("high_score_entries") if _profile != null else []
						_assert(not submitted_entries.is_empty() and submitted_entries[0]["name"] == "Ada", "app persists submitted high-score name")
						_assert(not submitted_entries.is_empty() and submitted_entries[0]["score"] == 1200, "app persists submitted high-score score")
						_assert(app.find_child("HighScoreScreen", true, false) != null, "app routes submitted score to high-score table")
						_assert_app_original_cursor(app, "score submission keeps the original cursor overlay for high-score table")
						if _audio != null and _audio.has_method("current_music_context"):
							_assert(String(_audio.call("current_music_context")) == AudioCueCatalogScript.CONTEXT_HIGH_SCORE, "score submission routes to high-score music context")
						var routed_high_score := app.find_child("HighScoreScreen", true, false)
						if routed_high_score != null:
							_assert(int(routed_high_score.call("highlighted_row_index")) == 0, "submitted high-score table highlights the last finished player")
							routed_high_score.emit_signal("back_requested")
							await process_frame
				await process_frame
				_assert(app.find_child("MainMenuScreen", true, false) != null, "app returns from submitted high-score table to main menu")
				_assert_app_original_cursor(app, "app keeps the original cursor overlay after returning to menu")
				if _audio != null and _audio.has_method("current_music_context"):
					_assert(String(_audio.call("current_music_context")) == AudioCueCatalogScript.CONTEXT_MAIN_MENU, "high-score back restores main-menu music context")
					_assert(String(_audio.call("current_music_name")) == "Abnormal", "high-score back restores original main-menu music")
				app_menu = app.find_child("MainMenuScreen", true, false)
				if app_menu != null:
					app_menu.emit_signal("high_score_requested")
					await process_frame
					var reopened_high_score := app.find_child("HighScoreScreen", true, false)
					_assert(reopened_high_score != null, "app can reopen high-score screen after returning to menu")
					if reopened_high_score != null:
						_assert(int(reopened_high_score.call("highlighted_row_index")) == 0, "reopened high-score screen keeps the last finished player highlighted")
						reopened_high_score.emit_signal("back_requested")
						await process_frame

	if _profile != null and _profile.has_method("set_save_path"):
		_profile.call("set_save_path", _test_profile_path("non_qualifying_route"), false)
	if _profile != null and _profile.has_method("submit_high_score"):
		for index in range(ProfileScript.HIGH_SCORE_TABLE_LIMIT):
			_profile.call("submit_high_score", "Player%d" % index, 1000 - index, index + 1, "Default")
	app_menu = app.find_child("MainMenuScreen", true, false)
	if app_menu != null:
		app_menu.emit_signal("start_game_requested")
		await process_frame
		var non_qualifying_episode_select := app.find_child("EpisodeSelectScreen", true, false)
		if non_qualifying_episode_select != null:
			non_qualifying_episode_select.emit_signal("episode_selected", "Default", 1)
			await process_frame
			var non_qualifying_game := app.find_child("GameScreen", true, false)
			_assert(non_qualifying_game != null, "app starts non-qualifying score test game")
			if non_qualifying_game != null:
				var non_qualifying_session = non_qualifying_game.call("current_game_session")
				if non_qualifying_session != null:
					non_qualifying_session.state = GameSessionScript.STATE_GAME_OVER
					non_qualifying_session.score = 1
					non_qualifying_session.display_level_number = 1
					non_qualifying_game.call("_input", _action_event(GameScreenScript.ACTION_LAUNCH_BALL))
					await process_frame
					_assert(app.find_child("MainMenuScreen", true, false) != null, "app returns non-qualifying game-over score to main menu")
					_assert_app_original_cursor(app, "non-qualifying game-over route restores the original cursor overlay")
	app_menu = app.find_child("MainMenuScreen", true, false)
	if app_menu != null:
		app_menu.emit_signal("start_game_requested")
		await process_frame
		var exit_episode_select := app.find_child("EpisodeSelectScreen", true, false)
		if exit_episode_select != null:
			exit_episode_select.emit_signal("episode_selected", "Default", 1)
			await process_frame
			var exit_game := app.find_child("GameScreen", true, false)
			_assert(exit_game != null, "app starts leave-board confirmation test game")
			if exit_game != null:
				var exit_session = exit_game.call("current_game_session")
				if exit_session != null:
					exit_session.score = 1200
					exit_session.display_level_number = 4
				exit_game.call("_input", _action_event(GameScreenScript.ACTION_TERMINATE_GAME))
				await process_frame
				_assert(exit_game.call("is_exit_confirmation_visible"), "app game opens leave-board confirmation on Escape")
				exit_game.call("_input", _key_event(KEY_Y, 121))
				await process_frame
				_assert(app.find_child("GameScreen", true, false) != null, "confirmed leave-board route stays on game-over summary before name entry")
				var exit_game_hud = exit_game.call("current_hud")
				if exit_game_hud != null:
					var exit_game_over_layout: Dictionary = exit_game_hud.call("game_over_layout")
					_assert(bool(exit_game_over_layout["visible"]), "app confirmed leave-board route shows game-over summary before name entry")
				exit_game.call("_input", _action_event(GameScreenScript.ACTION_LAUNCH_BALL))
				await process_frame
				var exit_name_entry := app.find_child("NameEntryScreen", true, false)
				_assert(exit_name_entry != null, "mouse-confirmed leave-board game-over summary routes to name entry")
				_assert_app_no_mouse_cursor(app, "leave-board route hides every mouse cursor for name entry")
				if _audio != null and _audio.has_method("current_music_context"):
					_assert(String(_audio.call("current_music_context")) == AudioCueCatalogScript.CONTEXT_NAME_ENTRY, "confirmed leave-board score uses name-entry music context")
				if exit_name_entry != null:
					exit_name_entry.call("set_player_name", "Exit")
					exit_name_entry.call("submit_name")
					await process_frame
					var exit_entries: Array = _profile.call("high_score_entries") if _profile != null else []
					_assert(not exit_entries.is_empty() and exit_entries[0]["name"] == "Exit", "confirmed leave-board name is saved to high-score table")
					_assert(not exit_entries.is_empty() and exit_entries[0]["score"] == 1200, "confirmed leave-board score is saved to high-score table")
					_assert(app.find_child("HighScoreScreen", true, false) != null, "confirmed leave-board submission routes to high-score table")
					_assert_app_original_cursor(app, "confirmed leave-board submission keeps the original cursor overlay for high-score table")
					if _audio != null and _audio.has_method("current_music_context"):
						_assert(String(_audio.call("current_music_context")) == AudioCueCatalogScript.CONTEXT_HIGH_SCORE, "confirmed leave-board submission uses high-score music context")
	app.queue_free()
	await process_frame
	Input.set_mouse_mode(saved_mouse_mode)


func _load_level_from_path(path: String):
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return null

	return LevelDataScript.from_dictionary(parsed, path)


func _make_level_from_rows(source_rows: Array, tail_bytes: Array = []) -> KrakoutLevelData:
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
	for index in range(LevelDataScript.LEVEL_TAIL_SIZE):
		var tail_value := 0
		if index < tail_bytes.size():
			tail_value = int(tail_bytes[index])
		level.level_tail_bytes.append(tail_value)
	return level


func _make_bonus_tail(bonus_counts: Array) -> Array[int]:
	var tail: Array[int] = []
	for index in range(LevelDataScript.LEVEL_TAIL_SIZE):
		var value := 0
		if index < bonus_counts.size():
			value = int(bonus_counts[index])
		tail.append(value)
	return tail


func _board_state_from_level(level: KrakoutLevelData):
	var state = BoardStateScript.new()
	state.load_level(level)
	return state


func _game_session_from_level(level: KrakoutLevelData):
	var session = GameSessionScript.new()
	session.load_level(level)
	return session


func _playing_session_from_level(level: KrakoutLevelData):
	var session = _game_session_from_level(level)
	session.force_ball(Vector2(300, 200), Vector2(-200, 0))
	return session


func _stack_bonus(session, type_id: int) -> void:
	session.bonus_stack.append({
		"type_id": type_id,
		"frame": 0,
		"frame_elapsed": 0.0,
	})


func _active_ball(
	position: Vector2,
	velocity: Vector2 = Vector2.ZERO,
	size: float = GameSessionScript.BALL_SIZE,
	type_id: int = GameSessionScript.BALL_TYPE_STANDARD
) -> Dictionary:
	return {
		"active": true,
		"position": position,
		"velocity": velocity,
		"size": size,
		"type_id": type_id,
		"previous_type_id": GameSessionScript.BALL_TYPE_STANDARD,
		"non_stricked_time_remaining": GameSessionScript.NON_STRICKED_DURATION_SECONDS if type_id == GameSessionScript.BALL_TYPE_NON_STRICKED else 0.0,
		"frame": 0,
		"frame_elapsed": 0.0,
		"speed_scale": GameSessionScript.BALL_DEFAULT_SPEED_SCALE,
		"target_speed": velocity.length(),
		"speed_hit_count": 0,
		"magnet_attached": false,
	}


func _projectile(projectile_type: int, position: Vector2) -> Dictionary:
	return {
		"active": true,
		"type": projectile_type,
		"position": position,
		"head_frame": 0,
		"head_frame_elapsed": 0.0,
		"trail_frame": 0,
		"trail_frame_elapsed": 0.0,
	}


func _action_event(action_name: String) -> InputEventAction:
	var event := InputEventAction.new()
	event.action = action_name
	event.pressed = true
	return event


func _key_event(
	keycode: Key,
	unicode := 0,
	shift_pressed := false,
	alt_pressed := false,
	ctrl_pressed := false
) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.unicode = unicode
	event.shift_pressed = shift_pressed
	event.alt_pressed = alt_pressed
	event.ctrl_pressed = ctrl_pressed
	event.pressed = true
	return event


func _mouse_button_event(button_index: MouseButton) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = button_index
	event.pressed = true
	return event


func _action_has_key(
	action_name: String,
	keycode: Key,
	ctrl_pressed := false,
	shift_pressed := false,
	alt_pressed := false
) -> bool:
	for event: InputEvent in InputMap.action_get_events(action_name):
		var key_event := event as InputEventKey
		if key_event == null:
			continue
		var matches_key := key_event.keycode == keycode or key_event.physical_keycode == keycode
		if matches_key \
			and key_event.ctrl_pressed == ctrl_pressed \
			and key_event.shift_pressed == shift_pressed \
			and key_event.alt_pressed == alt_pressed:
			return true
	return false


func _action_has_mouse_button(action_name: String, button_index: MouseButton) -> bool:
	for event: InputEvent in InputMap.action_get_events(action_name):
		var button_event := event as InputEventMouseButton
		if button_event != null and button_event.button_index == button_index:
			return true
	return false


func _test_profile_path(label: String) -> String:
	return "user://krakout_%s_profile_%d.cfg" % [label, Time.get_ticks_usec()]


func _test_legacy_high_score_path(label: String) -> String:
	return "user://krakout_%s_legacy_%d.high" % [label, Time.get_ticks_usec()]


func _project_file_path(relative_path: String) -> String:
	var project_root := ProjectSettings.globalize_path("res://")
	if not project_root.ends_with("/"):
		project_root += "/"
	return project_root + relative_path


func _shutdown_test_audio() -> void:
	if _audio != null and _audio.has_method("stop_all"):
		_audio.call("stop_all", true)


func _is_runtime_path(entry: Dictionary) -> bool:
	return String(entry.get("output_path", "")).begins_with("res://assets/krakout/")


func _indicator_for_icon(indicators: Array, icon_index: int) -> Dictionary:
	for indicator: Dictionary in indicators:
		if int(indicator.get("icon_index", -1)) == icon_index:
			return indicator
	return {}


func _find_summary(summaries: Array, slug: String) -> Dictionary:
	for summary: Dictionary in summaries:
		if summary.get("slug", "") == slug:
			return summary
	return {}


func _assert_app_original_cursor(app: Node, message: String) -> void:
	var cursor_overlay := app.find_child("KrakoutCursorOverlay", true, false)
	_assert(cursor_overlay != null, "%s exists" % message)
	if cursor_overlay == null:
		return
	_assert(bool(cursor_overlay.call("is_cursor_active")), "%s is active" % message)
	_assert(cursor_overlay.call("cursor_texture_size") == Vector2i(68, 58), "%s uses extracted Cursor texture" % message)
	_assert(cursor_overlay.call("logo_texture_size") == Vector2i(200, 240), "%s uses extracted Welogo animation sheet" % message)
	_assert(bool(app.call("is_system_cursor_hidden_for_menu")), "%s hides the system cursor" % message)
	if DisplayServer.get_name() != "headless":
		_assert(Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN, "%s applies hidden OS cursor mode" % message)


func _assert_app_original_cursor_animation(app: Node, message: String) -> void:
	var cursor_overlay := app.find_child("KrakoutCursorOverlay", true, false)
	_assert(cursor_overlay != null, "%s exists" % message)
	if cursor_overlay == null:
		return
	var first_frame := int(cursor_overlay.call("current_logo_frame_index"))
	cursor_overlay.call("advance_animation", 0.031)
	_assert(int(cursor_overlay.call("current_logo_frame_index")) == (first_frame + 1) % 30, "%s advances at original 30 ms cadence" % message)


func _assert_app_original_cursor_inactive(app: Node, message: String) -> void:
	var cursor_overlay := app.find_child("KrakoutCursorOverlay", true, false)
	_assert(cursor_overlay != null, "%s exists" % message)
	if cursor_overlay == null:
		return
	_assert(not bool(cursor_overlay.call("is_cursor_active")), "%s is inactive" % message)


func _assert_app_no_mouse_cursor(app: Node, message: String) -> void:
	var cursor_overlay := app.find_child("KrakoutCursorOverlay", true, false)
	_assert(cursor_overlay != null, "%s overlay exists" % message)
	if cursor_overlay == null:
		return
	_assert(not bool(cursor_overlay.call("is_cursor_active")), "%s disables the original cursor overlay" % message)
	_assert(bool(app.call("is_system_cursor_hidden_for_menu")), "%s hides the system cursor" % message)
	if DisplayServer.get_name() != "headless":
		_assert(Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN, "%s applies hidden OS cursor mode" % message)


func _payload_events(payloads: Array) -> Array[String]:
	var events: Array[String] = []
	for payload: Variant in payloads:
		if payload is Dictionary:
			var event_name := String(payload.get("event", ""))
			if not event_name.is_empty():
				events.append(event_name)
		else:
			events.append(String(payload))
	return events


func _assert(condition: bool, message: String) -> void:
	if condition:
		return

	_failures += 1
	push_error(message)
