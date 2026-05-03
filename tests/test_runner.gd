extends SceneTree

const AssetsScript := preload("res://src/autoloads/krakout_assets.gd")
const LevelsScript := preload("res://src/autoloads/krakout_levels.gd")
const ProfileScript := preload("res://src/autoloads/krakout_profile.gd")
const AudioScript := preload("res://src/autoloads/krakout_audio.gd")
const AudioCueCatalogScript := preload("res://src/audio/krakout_audio_cue_catalog.gd")
const LevelDataScript := preload("res://src/data/krakout_level_data.gd")
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
const ImpactEffectRendererScript := preload("res://src/render/impact_effect_renderer.gd")
const GameHudScript := preload("res://src/game/game_hud.gd")
const GameScreenScript := preload("res://src/game/game_screen.gd")
const BitmapTextScript := preload("res://src/render/krakout_bitmap_text.gd")
const MainMenuScreenScene := preload("res://scenes/menu/main_menu_screen.tscn")
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
	_validate_profile_service()
	_validate_audio_cue_catalog()
	await _validate_audio_service()
	_validate_playfield_renderer_shell()
	_validate_brick_semantics()
	_validate_original_rng()
	_validate_brick_atlas_mapping()
	_validate_bitmap_text_metrics()
	_validate_level_grid_renderer_defaults()
	await _validate_game_hud_presentation()
	_validate_gameplay_sheet_catalog()
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
	renderer.set_background_type(1)
	_assert(renderer.gameplay_background_source_rect() == Rect2(Vector2(50, 0), Vector2(50, 50)), "playfield renderer can switch background source tile")
	_assert(renderer.cycle_background_type() == 2, "playfield renderer cycles background source tiles")
	renderer.set_background_movable(false)
	_assert(not renderer.is_background_movable(), "playfield renderer records background movable setting")
	_assert(PlayfieldRendererScript.WALL_LEFT_X == 2, "left wall x remains original-screen aligned")
	_assert(PlayfieldRendererScript.WALL_RIGHT_X == 613, "right wall x remains original-screen aligned")
	_assert(PlayfieldRendererScript.WALL_TOP_Y == 36, "top wall y remains original-screen aligned")
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

	var converted_chain_state = _board_state_from_level(_make_level_from_rows([[1]]))
	_assert(converted_chain_state.convert_to_chain_explosion_tile(0, 0, 68), "board state can convert a tile into a delayed chain explosion")
	_assert(converted_chain_state.tile_at(0, 0) == 68, "converted chain tile is stored in board state")
	_assert(converted_chain_state.pending_chain_explosion_count() == 1, "converted chain tile is scheduled")


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
	_assert(session.ball_rect(session.visible_balls()[0]).size == Vector2(18, 18), "game session defaults to original standard ball size")
	_assert(session.racket_segment_count == GameSessionScript.RACKET_DEFAULT_SEGMENTS, "game session defaults to original racket segment count")
	_assert(session.current_racket_height() == GameSessionScript.RACKET_HEIGHT, "game session defaults to original racket height")
	_assert(session.racket_rect().size == Vector2(GameSessionScript.RACKET_WIDTH, GameSessionScript.RACKET_HEIGHT), "game session default racket rect uses original size")
	_assert(session.current_racket_visual_mode() == GameSessionScript.RACKET_VISUAL_MODE_NORMAL, "game session starts with original normal racket insert")
	_assert(session.score == 0, "game session starts with zero score")
	_assert(session.displayed_score == 0, "game session starts with zero displayed score")
	_assert(session.lives_remaining == GameSessionScript.INITIAL_LIVES, "game session starts with original spare ball count")
	_assert(session.points_to_next_extra_life == GameSessionScript.EXTRA_LIFE_SCORE_STEP, "game session starts with original extra life threshold")
	_assert(session.display_level_number == 1, "game session displays source level number")
	_assert(session.active_bonus_indicators().is_empty(), "game session exposes no active status indicators before timed effects exist")
	_assert(session.active_monster_count() == 0, "game session starts without active monsters")
	_assert(session.active_bee_count() == 0, "game session starts without active bees")
	_assert(session.visible_impact_effects().is_empty(), "game session starts without impact effects")
	_assert(not session.is_racket_stunned(), "game session starts with active racket control")
	_assert(session.pop_audio_events().is_empty(), "game session starts without queued SFX events")

	session.move_racket_to(-100.0)
	_assert(session.racket_rect().position.y == GameSessionScript.RACKET_MIN_Y, "racket clamps to top bound")
	session.move_racket_to(10000.0)
	_assert(session.racket_rect().end.y == GameSessionScript.RACKET_MAX_BOTTOM, "racket clamps to bottom bound")
	_assert(session.first_ball_position().y > session.racket_rect().position.y, "ready ball follows racket")
	_assert(session.launch_ready_ball(), "ready ball launches")
	_assert(session.state == GameSessionScript.STATE_PLAYING, "game session enters playing state")
	_assert(session.first_ball_velocity().x < 0.0, "launched ball starts toward board")
	_assert(session.first_ball_velocity() == Vector2(-300, 0), "launched ball starts at original effective substep speed")
	_assert(is_equal_approx(session.first_ball_velocity().length(), 300.0), "launched ball speed matches original default cadence")
	_assert(session.pop_audio_events() == [GameSessionScript.SFX_EVENT_BALL_LAUNCH], "launch queues semantic SFX event")

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
	_assert(racket_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_RACKET_BOUNCE], "racket bounce queues semantic SFX event")

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
	_assert(missed_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_LIFE_LOST], "spare-ball miss queues life-lost SFX event")
	for miss_index in range(GameSessionScript.INITIAL_LIVES):
		missed_session.force_ball(Vector2(GameSessionScript.BALL_LOST_X + 1.0, 350), Vector2(120, 0))
		missed_session.update(0.01)
	_assert(missed_session.state == GameSessionScript.STATE_GAME_OVER, "losing with zero spare balls enters game over")
	_assert(missed_session.visible_lives() == 0, "game over display clamps spare balls at zero")
	_assert(missed_session.active_ball_count() == 0, "game over hides active balls")
	var missed_audio_events: Array[String] = missed_session.pop_audio_events()
	_assert(missed_audio_events.has(GameSessionScript.SFX_EVENT_GAME_OVER), "final miss queues game-over SFX event")

	var brick_session = _game_session_from_level(_make_level_from_rows([[1]]))
	brick_session.force_ball(PlayfieldSpecScript.GRID_ORIGIN + Vector2(2, 2), Vector2(-80, 0))
	brick_session.update(0.01)
	_assert(brick_session.board_state.tile_at(0, 0) == 0, "ball hit clears brick through board state")
	_assert(brick_session.consume_board_changed(), "brick hit marks board for redraw")
	_assert(brick_session.score == GameSessionScript.BRICK_SCORE, "brick hit awards original score increment")
	var brick_audio_events: Array[String] = brick_session.pop_audio_events()
	_assert(brick_audio_events.has(GameSessionScript.SFX_EVENT_BRICK_CLEAR), "brick clear queues IDA-backed SFX event")
	_assert(brick_audio_events.has(GameSessionScript.SFX_EVENT_LEVEL_COMPLETE), "final brick clear queues level-complete SFX event")
	for catchup_index in range(6):
		brick_session.update(0.0)
	_assert(brick_session.displayed_score == GameSessionScript.BRICK_SCORE, "displayed score catches up gradually")
	_assert(brick_session.state == GameSessionScript.STATE_LEVEL_COMPLETE, "clearing final required brick completes level")

	var chain_session = _game_session_from_level(_make_level_from_rows([[43, 68]]))
	chain_session.force_ball(PlayfieldSpecScript.GRID_ORIGIN + Vector2(2, 2), Vector2(-80, 0))
	chain_session.update(0.01)
	_assert(chain_session.board_state.tile_at(0, 0) == 0, "chain tile hit clears source tile")
	_assert(chain_session.board_state.tile_at(1, 0) == 68, "chain tile hit leaves neighbor pending")
	_assert(chain_session.board_state.pending_chain_explosion_count() == 1, "chain tile hit schedules delayed neighbor")
	_assert(chain_session.score == GameSessionScript.BRICK_SCORE, "chain hit scores immediate cleared tile")
	_assert(chain_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_CHAIN_EXPLOSION], "chain tile hit queues chain-explosion SFX event")
	chain_session.update(0.031)
	_assert(chain_session.board_state.tile_at(1, 0) == 0, "delayed chain explosion clears neighbor")
	_assert(chain_session.score == GameSessionScript.BRICK_SCORE * 2, "delayed chain explosion awards score")
	_assert(chain_session.state == GameSessionScript.STATE_LEVEL_COMPLETE, "chain explosion can complete level")
	var delayed_chain_audio_events: Array[String] = chain_session.pop_audio_events()
	_assert(delayed_chain_audio_events.has(GameSessionScript.SFX_EVENT_CHAIN_EXPLOSION), "delayed chain clear queues chain-explosion SFX event")
	_assert(delayed_chain_audio_events.has(GameSessionScript.SFX_EVENT_LEVEL_COMPLETE), "delayed chain clear queues level-complete SFX event")

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
	_assert(bonus_spawn_session.score == GameSessionScript.BRICK_SCORE, "bonus-eligible brick hit still awards brick score")
	_assert(bonus_spawn_session.remaining_bonus_stock == 0, "bonus spawn consumes one original stock counter")
	_assert(bonus_spawn_session.bonus_stock_counts[0] == 0, "bonus spawn decrements selected stock")
	var spawned_bonuses: Array = bonus_spawn_session.visible_falling_bonuses()
	_assert(spawned_bonuses.size() == 1, "eligible brick hit can spawn a falling bonus")
	if spawned_bonuses.size() == 1:
		_assert(int(spawned_bonuses[0]["type_id"]) == 0, "spawned bonus keeps selected original type")
		_assert(spawned_bonuses[0]["position"] == PlayfieldSpecScript.GRID_ORIGIN, "spawned bonus starts at source brick position")
	_assert(bonus_spawn_session.pop_audio_events().has(GameSessionScript.SFX_EVENT_BONUS_SPAWN), "bonus spawn queues semantic SFX event")

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
		_assert(is_equal_approx(moved_bonuses[0]["position"].x, 101.5), "falling bonus advances by original x step")
		_assert(int(moved_bonuses[0]["angle"]) == 3, "falling bonus advances by original angle step")
		_assert(int(moved_bonuses[0]["frame"]) == 1, "falling bonus animation advances at original cadence")

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

	var chain_selector_session = _game_session_from_level(_make_level_from_rows([[1]], _make_bonus_tail([1])))
	chain_selector_session.set_bonus_rng_seed(23)
	chain_selector_session.force_bonus_drop_ready()
	chain_selector_session.force_ball(PlayfieldSpecScript.GRID_ORIGIN + Vector2(2, 2), Vector2(-80, 0))
	chain_selector_session.update(0.01)
	_assert(chain_selector_session.board_state.tile_at(0, 0) == 68, "random bonus selector can convert a hit brick into a chain tile")
	_assert(chain_selector_session.board_state.pending_chain_explosion_count() == 1, "converted random chain tile is scheduled")
	_assert(chain_selector_session.score == 0, "converted chain tile waits for delayed explosion scoring")
	chain_selector_session.update(0.031)
	_assert(chain_selector_session.board_state.tile_at(0, 0) == 0, "converted chain tile clears after delay")
	_assert(chain_selector_session.score == GameSessionScript.BRICK_SCORE, "converted chain explosion awards brick score")

	var inactive_bonus_session = _game_session_from_level(_make_level_from_rows([[1]]))
	_stack_bonus(inactive_bonus_session, GameSessionScript.BONUS_EXTRA_LIFE)
	var inactive_bonus_result: Dictionary = inactive_bonus_session.activate_next_bonus()
	_assert(inactive_bonus_result["status"] == "inactive", "bonus activation waits for playing state")
	_assert(inactive_bonus_session.bonus_stack_entries().size() == 1, "inactive bonus activation preserves stack")

	var empty_bonus_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	var empty_bonus_result: Dictionary = empty_bonus_session.activate_next_bonus()
	_assert(empty_bonus_result["status"] == "empty", "empty bonus stack reports empty activation")

	var unsupported_bonus_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	_stack_bonus(unsupported_bonus_session, GameSessionScript.BONUS_ADD_FIREBALL)
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
	_assert(projectile_hit_session.score == GameSessionScript.BRICK_SCORE, "projectile hit awards brick score")
	_assert(projectile_hit_session.active_projectile_count() == 0, "continuous projectile deactivates after brick hit")
	var projectile_hit_audio_events: Array[String] = projectile_hit_session.pop_audio_events()
	_assert(projectile_hit_audio_events.has(GameSessionScript.SFX_EVENT_PROJECTILE_HIT), "projectile brick hit queues projectile-hit SFX event")
	_assert(projectile_hit_audio_events.has(GameSessionScript.SFX_EVENT_BRICK_CLEAR), "projectile brick hit queues brick-clear SFX event")

	var projectile_expire_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	var expiring_projectiles: Array[Dictionary] = [_projectile(
		GameSessionScript.PROJECTILE_TYPE_CONTINUOUS,
		Vector2(GameSessionScript.PROJECTILE_EXPIRE_X + 1.0, 200)
	)]
	projectile_expire_session.projectiles = expiring_projectiles
	projectile_expire_session.update(0.0)
	_assert(projectile_expire_session.active_projectile_count() == 0, "projectile expires at original left bound")

	var monster_spawn_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	monster_spawn_session.set_monster_rng_seed(3)
	monster_spawn_session.force_monster_spawn_ready()
	monster_spawn_session.update(0.0)
	_assert(monster_spawn_session.active_monster_count() == 1, "monster spawn gate creates first original monster slot")
	var spawned_monsters: Array = monster_spawn_session.visible_monsters()
	if spawned_monsters.size() == 1:
		_assert(int(spawned_monsters[0]["type_id"]) == 3, "first spawned monster uses original type-cycle entry")
		_assert(monster_spawn_session.monster_rect(spawned_monsters[0]).size == GameSessionScript.MONSTER_COLLISION_SIZE, "monster collision rect uses original 26px box")
	_assert(monster_spawn_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_MONSTER_SPAWN], "monster spawn queues semantic SFX event")
	monster_spawn_session.force_monster_spawn_ready()
	monster_spawn_session.update(0.0)
	spawned_monsters = monster_spawn_session.visible_monsters()
	if spawned_monsters.size() >= 2:
		_assert(int(spawned_monsters[1]["type_id"]) == 6, "second spawned monster uses original type-cycle entry")
	monster_spawn_session.force_monster_spawn_ready()
	monster_spawn_session.update(0.0)
	spawned_monsters = monster_spawn_session.visible_monsters()
	if spawned_monsters.size() >= 3:
		_assert(int(spawned_monsters[2]["type_id"]) == 10, "third spawned monster uses original type-cycle entry")
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
		_assert(moving_monsters[0]["position"] == Vector2(201, 200), "type 3 monster advances one original step")
		_assert(int(moving_monsters[0]["frame"]) == 1, "monster animation advances at original cadence")
	monster_motion_session.monsters[0]["age"] = GameSessionScript.MONSTER_LIFETIME_SECONDS - 0.01
	monster_motion_session.update(0.02)
	_assert(monster_motion_session.active_monster_count() == 0, "monster expires after original lifetime")

	var monster_boundary_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	monster_boundary_session.force_monster(
		Vector2(PlayfieldSpecScript.WALL_INNER_LEFT_X - GameSessionScript.MONSTER_COLLISION_OFFSET.x - 4.0, 200),
		6,
		180
	)
	monster_boundary_session.update(0.0)
	var bounded_monsters: Array = monster_boundary_session.visible_monsters()
	_assert(bounded_monsters.size() == 1, "monster remains active after hitting the playfield boundary")
	if bounded_monsters.size() == 1:
		_assert(monster_boundary_session.monster_rect(bounded_monsters[0]).position.x == PlayfieldSpecScript.WALL_INNER_LEFT_X, "monster boundary collision clamps to original inner wall")
		_assert(int(bounded_monsters[0]["angle"]) == 0, "monster boundary collision reflects horizontal motion")

	var monster_ball_hit_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	monster_ball_hit_session.set_collision_rng_seed(1)
	monster_ball_hit_session.force_ball(Vector2(200, 200), Vector2.ZERO)
	monster_ball_hit_session.force_monster(Vector2(200, 200), 3, 0)
	monster_ball_hit_session.update(0.0)
	_assert(monster_ball_hit_session.active_monster_count() == 0, "ball collision removes active monster")
	_assert(monster_ball_hit_session.score == GameSessionScript.MONSTER_BALL_HIT_SCORE, "ball collision awards original ball-contact monster score")
	_assert(not monster_ball_hit_session.first_ball_velocity().is_zero_approx(), "ball collision changes the ball trajectory")
	_assert(monster_ball_hit_session.visible_impact_effects().size() == 1, "ball collision spawns monster hit VFX")
	_assert(monster_ball_hit_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_MONSTER_HIT], "monster collision queues monster-hit SFX event")
	monster_ball_hit_session.update(GameSessionScript.IMPACT_EFFECT_DURATION_SECONDS)
	_assert(monster_ball_hit_session.visible_impact_effects().is_empty(), "monster hit VFX expires through the session effect pool")

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
	_assert(bee_spawn_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_BEE_SPAWN], "bee spawn queues EffBee SFX event")
	bee_spawn_session.update(GameSessionScript.BEE_FRAME_SECONDS)
	spawned_bees = bee_spawn_session.visible_bees()
	if spawned_bees.size() == 1:
		_assert(spawned_bees[0]["position"].x == GameSessionScript.BEE_SPAWN_X + GameSessionScript.BEE_STEP_X, "bee advances by original 3px step")
		_assert(int(spawned_bees[0]["frame"]) == 1, "bee animation advances through original 5ms frames")

	var bee_ball_hit_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	bee_ball_hit_session.force_ball(Vector2(200, 200), Vector2.ZERO)
	bee_ball_hit_session.force_bee(Vector2(200, 200))
	bee_ball_hit_session.update(0.0)
	_assert(bee_ball_hit_session.active_bee_count() == 0, "ball collision removes active bee")
	_assert(bee_ball_hit_session.score == GameSessionScript.BEE_BALL_HIT_SCORE, "ball collision awards bee ball-contact score")
	_assert(not bee_ball_hit_session.first_ball_velocity().is_zero_approx(), "bee ball collision changes the ball trajectory")
	_assert(not bee_ball_hit_session.is_racket_stunned(), "bee ball collision does not stun the racket")
	_assert(bee_ball_hit_session.visible_impact_effects().size() == 1, "bee ball collision spawns impact VFX")
	_assert(bee_ball_hit_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_MONSTER_HIT], "bee ball collision queues monster-hit SFX event")

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
	_assert(bee_racket_hit_session.visible_impact_effects().size() == 1, "bee hit spawns impact VFX")
	_assert(bee_racket_hit_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_MONSTER_HIT], "bee hit queues monster-hit SFX event")

	var bee_expire_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	bee_expire_session.force_bee(Vector2(GameSessionScript.BEE_EXPIRE_X - 1.0, 100))
	bee_expire_session.update(0.0)
	_assert(bee_expire_session.active_bee_count() == 0, "bee expires at original right bound")

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
	_assert(add_ball_session.pop_audio_events() == [GameSessionScript.SFX_EVENT_BONUS_APPLY], "applied non-projectile bonus queues bonus-apply SFX event")

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

	var extra_life_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	_stack_bonus(extra_life_session, GameSessionScript.BONUS_EXTRA_LIFE)
	extra_life_session.activate_next_bonus()
	_assert(extra_life_session.lives_remaining == GameSessionScript.INITIAL_LIVES + 1, "extra-life bonus increments spare balls")

	var destroy_ball_session = _playing_session_from_level(_make_level_from_rows([[1]]))
	_stack_bonus(destroy_ball_session, GameSessionScript.BONUS_ADD_STANDARD_BALL)
	destroy_ball_session.activate_next_bonus()
	_stack_bonus(destroy_ball_session, GameSessionScript.BONUS_DESTROY_ONE_BALL)
	var destroy_ball_result: Dictionary = destroy_ball_session.activate_next_bonus()
	_assert(destroy_ball_result["effect"] == "destroy_one_ball", "destroy-ball bonus reports effect")
	_assert(destroy_ball_session.active_ball_count() == 1, "destroy-ball bonus removes one active ball")

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
	var jump_level_audio_events: Array[String] = jump_level_session.pop_audio_events()
	_assert(jump_level_audio_events.has(GameSessionScript.SFX_EVENT_LEVEL_COMPLETE), "jump-level bonus queues level-complete SFX event")
	_assert(jump_level_audio_events.has(GameSessionScript.SFX_EVENT_BONUS_APPLY), "jump-level bonus queues bonus-apply SFX event")


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

	var ball_renderer: KrakoutBallRenderer = BallRendererScript.new()
	_assert(ball_renderer.source_rect_for_size(10.0, 0) == Rect2(Vector2(1, 1), Vector2(10, 10)), "ball renderer maps smallest atlas row")
	_assert(ball_renderer.source_rect_for_size(GameSessionScript.BALL_SIZE, 0) == Rect2(Vector2(1, 13), Vector2(18, 18)), "ball renderer maps default standard ball atlas row")
	_assert(ball_renderer.source_rect_for_size(26.0, 2) == Rect2(Vector2(57, 33), Vector2(26, 26)), "ball renderer maps increased ball frame")
	_assert(ball_renderer.source_rect_for_size(GameSessionScript.BALL_MAX_SIZE, 9) == Rect2(Vector2(397, 97), Vector2(42, 42)), "ball renderer maps largest atlas row")
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

	var monster_renderer = MonsterRendererScript.new()
	_assert(monster_renderer.source_rect_for_monster(3, 0) == Rect2(Vector2(96, 0), Vector2(32, 32)), "monster renderer maps original type 3 frame")
	_assert(monster_renderer.source_rect_for_monster(10, 7) == Rect2(Vector2(320, 224), Vector2(32, 32)), "monster renderer maps original type 10 animation row")
	monster_renderer.free()

	var bee_renderer = BeeRendererScript.new()
	_assert(bee_renderer.source_rect_for_bee(0) == Rect2(Vector2(0, 0), Vector2(48, 40)), "bee renderer maps original first bee frame")
	_assert(bee_renderer.source_rect_for_bee(5) == Rect2(Vector2(0, 200), Vector2(48, 40)), "bee renderer maps original final bee frame")
	bee_renderer.free()

	var impact_renderer = ImpactEffectRendererScript.new()
	_assert(impact_renderer.source_rect_for_effect(GameSessionScript.IMPACT_EFFECT_KIND_MONSTER_HIT, 0) == Rect2(Vector2(20, 0), Vector2(10, 10)), "impact renderer maps original monster-hit effect cell")
	_assert(impact_renderer.source_rect_for_effect(GameSessionScript.IMPACT_EFFECT_KIND_MONSTER_HIT, 3) == Rect2(Vector2(10, 10), Vector2(10, 10)), "impact renderer advances through original effect cells")
	impact_renderer.free()


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
		GameScreenScript.ACTION_PAUSE,
		GameScreenScript.ACTION_TERMINATE_GAME,
		GameScreenScript.ACTION_CYCLE_BACKGROUND,
	]
	for action_name: String in expected_actions:
		_assert(InputMap.has_action(action_name), "project input action exists: %s" % action_name)

	_assert(_action_has_mouse_button(GameScreenScript.ACTION_LAUNCH_BALL, MOUSE_BUTTON_LEFT), "launch action binds left mouse button")
	_assert(_action_has_mouse_button(GameScreenScript.ACTION_FIRE_PADDLE, MOUSE_BUTTON_RIGHT), "shooting-paddle action binds right mouse button")
	_assert(_action_has_key(GameScreenScript.ACTION_USE_BONUS, KEY_SPACE), "use-bonus action binds Space")
	_assert(_action_has_key(GameScreenScript.ACTION_TOGGLE_BONUS_STACK, KEY_TAB), "bonus-stack action binds Tab")
	_assert(_action_has_key(GameScreenScript.ACTION_TOGGLE_BALL_TRACKS, KEY_T, true), "ball-tracks action binds Ctrl+T")
	_assert(_action_has_key(GameScreenScript.ACTION_TOGGLE_FPS, KEY_F5), "FPS action binds F5")
	_assert(_action_has_key(GameScreenScript.ACTION_PAUSE, KEY_P), "pause action binds P")
	_assert(_action_has_key(GameScreenScript.ACTION_TERMINATE_GAME, KEY_ESCAPE), "terminate-game action binds Escape")
	_assert(_action_has_key(GameScreenScript.ACTION_CYCLE_BACKGROUND, KEY_G), "background-cycle action binds G")


func _validate_profile_service() -> void:
	var save_path := _test_profile_path("profile_service")
	var profile = ProfileScript.new()
	profile.set_save_path(save_path, false)
	_assert(profile.best_score() == 0, "profile defaults high score to zero")
	_assert(profile.bonus_stack_visible(), "profile defaults bonus stack visible")
	_assert(profile.ball_tracks_visible(), "profile defaults ball tracks visible")
	_assert(not profile.fps_visible(), "profile defaults FPS hidden")
	_assert(profile.background_movable(), "profile defaults background movable from original config")
	_assert(profile.background_type() == 2, "profile defaults to original BgType")
	_assert(profile.music_enabled(), "profile defaults music enabled")
	_assert(profile.sfx_enabled(), "profile defaults SFX enabled")
	_assert(profile.music_volume() == 80, "profile defaults music volume")
	_assert(profile.sfx_volume() == 85, "profile defaults SFX volume")
	_assert(profile.record_score(885), "profile records a new high score")
	_assert(profile.best_score() == 885, "profile exposes recorded high score")
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
	_assert(profile.set_background_type(1), "profile persists background type setting")
	_assert(profile.set_music_enabled(false), "profile persists disabled music setting")
	_assert(profile.set_sfx_enabled(false), "profile persists disabled SFX setting")
	_assert(profile.set_music_volume(35), "profile persists music volume setting")
	_assert(profile.set_sfx_volume(120), "profile clamps and persists SFX volume setting")

	var reloaded_profile = ProfileScript.new()
	reloaded_profile.set_save_path(save_path, true)
	_assert(reloaded_profile.best_score() == 885, "profile reloads persisted high score")
	_assert(not reloaded_profile.bonus_stack_visible(), "profile reloads bonus stack setting")
	_assert(not reloaded_profile.ball_tracks_visible(), "profile reloads ball tracks setting")
	_assert(reloaded_profile.fps_visible(), "profile reloads FPS setting")
	_assert(not reloaded_profile.background_movable(), "profile reloads background movable setting")
	_assert(reloaded_profile.background_type() == 1, "profile reloads background type setting")
	_assert(not reloaded_profile.music_enabled(), "profile reloads music enabled setting")
	_assert(not reloaded_profile.sfx_enabled(), "profile reloads SFX enabled setting")
	_assert(reloaded_profile.music_volume() == 35, "profile reloads music volume setting")
	_assert(reloaded_profile.sfx_volume() == 100, "profile reloads clamped SFX volume setting")
	_assert(reloaded_profile.set_best_score(1200), "profile can replace high score with a higher value")

	var final_profile = ProfileScript.new()
	final_profile.set_save_path(save_path, true)
	_assert(final_profile.best_score() == 1200, "profile persists updated high score")
	_assert(final_profile.background_type() == 1, "profile keeps presentation settings when high score changes")
	_assert(final_profile.music_volume() == 35, "profile keeps audio settings when high score changes")

	var table_path := _test_profile_path("profile_table")
	var table_profile = ProfileScript.new()
	table_profile.set_save_path(table_path, false)
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
	var reloaded_table_profile = ProfileScript.new()
	reloaded_table_profile.set_save_path(table_path, true)
	_assert(reloaded_table_profile.high_score_entries().size() == ProfileScript.HIGH_SCORE_TABLE_LIMIT, "profile reloads persisted high-score table")
	_assert(reloaded_table_profile.best_score() == 1011, "profile best score follows table leader")

	profile.free()
	reloaded_profile.free()
	final_profile.free()
	table_profile.free()
	reloaded_table_profile.free()


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
	_assert(not AudioCueCatalogScript.has_sfx_event("missing_sfx_event"), "audio cue catalog rejects unknown SFX events")

	var expected_sfx_names := {
		GameSessionScript.SFX_EVENT_BALL_LAUNCH: "eff05",
		GameSessionScript.SFX_EVENT_RACKET_BOUNCE: "eff07",
		GameSessionScript.SFX_EVENT_BRICK_CLEAR: "eff23",
		GameSessionScript.SFX_EVENT_CHAIN_EXPLOSION: "eff10",
		GameSessionScript.SFX_EVENT_BONUS_SPAWN: "eff11",
		GameSessionScript.SFX_EVENT_BONUS_COLLECT: "eff15",
		GameSessionScript.SFX_EVENT_PROJECTILE_FIRE: "eff08",
		GameSessionScript.SFX_EVENT_MONSTER_SPAWN: "eff13",
		GameSessionScript.SFX_EVENT_MONSTER_HIT: "eff09",
		GameSessionScript.SFX_EVENT_BEE_SPAWN: "EffBee",
		GameSessionScript.SFX_EVENT_LIFE_LOST: "eff16",
		GameSessionScript.SFX_EVENT_LEVEL_COMPLETE: "eff19",
		GameSessionScript.SFX_EVENT_GAME_OVER: "eff18",
	}
	for event_name: String in expected_sfx_names.keys():
		_assert(
			AudioCueCatalogScript.sfx_name_for_event(event_name) == expected_sfx_names[event_name],
			"audio cue catalog maps %s to IDA-backed %s" % [event_name, expected_sfx_names[event_name]]
		)
	_assert(AudioCueCatalogScript.sfx_name_for_event(GameSessionScript.SFX_EVENT_BACK_WALL_BOUNCE) == "", "audio cue catalog leaves unproven back-wall bounce silent")
	_assert(AudioCueCatalogScript.sfx_name_for_event(GameSessionScript.SFX_EVENT_BONUS_APPLY) == "", "audio cue catalog leaves generic bonus-apply silent")
	_assert(AudioCueCatalogScript.sfx_name_for_event(GameSessionScript.SFX_EVENT_PROJECTILE_HIT) == "", "audio cue catalog leaves generic projectile-hit silent")
	_assert(AudioCueCatalogScript.sfx_name_for_event("missing_sfx_event") == "", "audio cue catalog leaves unknown SFX events silent")
	var sfx_events: Array[String] = AudioCueCatalogScript.known_sfx_events()
	_assert(sfx_events.has(GameSessionScript.SFX_EVENT_BONUS_APPLY), "audio cue catalog exposes bonus-apply event in known event list")
	_assert(sfx_events.has(GameSessionScript.SFX_EVENT_BEE_SPAWN), "audio cue catalog exposes bee-spawn event in known event list")
	_assert(sfx_events.has(GameSessionScript.SFX_EVENT_GAME_OVER), "audio cue catalog exposes game-over event in known event list")


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
	_assert(_audio.has_method("sfx_name_for_event"), "audio service exposes SFX event lookup")
	_assert(_audio.has_method("has_sfx_event"), "audio service exposes known SFX event lookup")
	_assert(bool(_audio.call("music_stream_exists", "theme1")), "audio service resolves extracted music track")
	_assert(bool(_audio.call("music_stream_exists", "theme2")), "audio service resolves high-score music track")
	_assert(bool(_audio.call("music_stream_exists", "theme5")), "audio service resolves credits music track")
	_assert(bool(_audio.call("music_stream_exists", "theme3")), "audio service resolves name-entry music track")
	_assert(bool(_audio.call("music_stream_exists", "theme4")), "audio service resolves gameplay music track")
	_assert(bool(_audio.call("music_stream_exists", "Abnormal")), "audio service resolves abnormal music track")
	_assert(bool(_audio.call("sfx_stream_exists", "eff01")), "audio service resolves extracted SFX")
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
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_BALL_LAUNCH)) == "eff05", "audio service maps ball-launch SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_RACKET_BOUNCE)) == "eff07", "audio service maps racket-bounce SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_BONUS_SPAWN)) == "eff11", "audio service maps bonus-spawn SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_BONUS_COLLECT)) == "eff15", "audio service maps bonus-collect SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_PROJECTILE_FIRE)) == "eff08", "audio service maps projectile-fire SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_MONSTER_SPAWN)) == "eff13", "audio service maps monster-spawn SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_MONSTER_HIT)) == "eff09", "audio service maps monster-hit SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_BEE_SPAWN)) == "EffBee", "audio service maps bee-spawn SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_LIFE_LOST)) == "eff16", "audio service maps life-lost SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_LEVEL_COMPLETE)) == "eff19", "audio service maps level-complete SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_GAME_OVER)) == "eff18", "audio service maps game-over SFX event")
	_assert(String(_audio.call("sfx_name_for_event", GameSessionScript.SFX_EVENT_BONUS_APPLY)) == "", "audio service leaves generic bonus-apply unmapped")

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

	root.add_child(hud)
	await process_frame
	hud.refresh()
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
	_assert(ResourceLoader.exists("res://scenes/menu/rules_screen.tscn"), "rules scene exists")
	_assert(ResourceLoader.exists("res://scenes/menu/high_score_screen.tscn"), "high score scene exists")
	_assert(ResourceLoader.exists("res://scenes/menu/name_entry_screen.tscn"), "name entry scene exists")
	_assert(ResourceLoader.exists("res://scenes/menu/options_screen.tscn"), "options scene exists")
	_assert(ResourceLoader.exists("res://scenes/menu/credits_screen.tscn"), "credits scene exists")
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

	if _profile != null and _profile.has_method("set_save_path"):
		_profile.call("set_save_path", _test_profile_path("menu_screens"), false)
	if _profile != null and _profile.has_method("set_best_score"):
		_profile.call("set_best_score", 321)

	var rules_screen := RulesScreenScene.instantiate()
	root.add_child(rules_screen)
	await process_frame
	_assert(rules_screen.has_signal("back_requested"), "rules screen exposes back signal")
	_assert(rules_screen.find_child("BackButton", true, false) != null, "rules screen creates back button")
	_assert(String(rules_screen.call("screen_title")) == "Game Rules", "rules screen exposes title")
	rules_screen.queue_free()

	var credits_screen := CreditsScreenScene.instantiate()
	root.add_child(credits_screen)
	await process_frame
	_assert(credits_screen.has_signal("back_requested"), "credits screen exposes back signal")
	_assert(credits_screen.find_child("BackButton", true, false) != null, "credits screen creates back button")
	_assert(String(credits_screen.call("screen_title")) == "Credits", "credits screen exposes title")
	credits_screen.queue_free()

	var high_score_screen := HighScoreScreenScene.instantiate()
	root.add_child(high_score_screen)
	await process_frame
	_assert(high_score_screen.has_signal("back_requested"), "high score screen exposes back signal")
	_assert(high_score_screen.find_child("BackButton", true, false) != null, "high score screen creates back button")
	_assert(int(high_score_screen.call("best_score")) == 321, "high score screen reads persisted high score")
	var high_score_entries: Array = high_score_screen.call("high_score_entries")
	_assert(high_score_entries.size() == 1, "high score screen reads profile table entries")
	_assert(high_score_entries[0]["score"] == 321, "high score screen mirrors legacy best in table view")
	high_score_screen.queue_free()

	var name_entry_screen := NameEntryScreenScene.instantiate()
	root.add_child(name_entry_screen)
	await process_frame
	_assert(name_entry_screen.has_signal("score_submitted"), "name entry screen exposes score-submitted signal")
	_assert(name_entry_screen.has_signal("cancel_requested"), "name entry screen exposes cancel signal")
	_assert(name_entry_screen.find_child("NameLabel", true, false) != null, "name entry screen creates editable name label")
	_assert(name_entry_screen.find_child("SubmitButton", true, false) != null, "name entry screen creates submit button")
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
		_profile.call("set_music_volume", 25)
		_profile.call("set_sfx_volume", 45)
		_profile.call("set_bonus_stack_visible", false)
		_profile.call("set_ball_tracks_visible", false)
		_profile.call("set_fps_visible", true)
		_profile.call("set_background_movable", false)
		_profile.call("set_background_type", 1)

	var options_screen := OptionsScreenScene.instantiate()
	root.add_child(options_screen)
	await process_frame
	_assert(options_screen.has_signal("back_requested"), "options screen exposes back signal")
	_assert(options_screen.find_child("SoundSliderArt", true, false) != null, "options screen loads original sound slider art")
	_assert(options_screen.find_child("BackButton", true, false) != null, "options screen creates back button")
	_assert(options_screen.find_child("StartMusicButton", true, false) == null, "options screen does not expose provisional music preview")
	var options_snapshot: Dictionary = options_screen.call("settings_snapshot")
	_assert(not bool(options_snapshot["music_enabled"]), "options screen loads music enabled setting")
	_assert(not bool(options_snapshot["sfx_enabled"]), "options screen loads SFX enabled setting")
	_assert(int(options_snapshot["music_volume"]) == 25, "options screen loads music volume")
	_assert(int(options_snapshot["sfx_volume"]) == 45, "options screen loads SFX volume")
	_assert(not bool(options_snapshot["bonus_stack_visible"]), "options screen loads bonus-stack setting")
	_assert(not bool(options_snapshot["ball_tracks_visible"]), "options screen loads ball-track setting")
	_assert(bool(options_snapshot["fps_visible"]), "options screen loads FPS setting")
	_assert(not bool(options_snapshot["background_movable"]), "options screen loads background-movable setting")
	_assert(int(options_snapshot["background_type"]) == 1, "options screen loads background type")
	options_screen.call("set_music_enabled", true)
	options_screen.call("set_sfx_enabled", true)
	options_screen.call("set_music_volume", 55)
	options_screen.call("set_sfx_volume", 65)
	options_screen.call("set_bonus_stack_visible", true)
	options_screen.call("set_ball_tracks_visible", true)
	options_screen.call("set_fps_visible", false)
	options_screen.call("set_background_movable", true)
	options_screen.call("set_background_type", 2)
	await process_frame
	if _profile != null:
		_assert(bool(_profile.call("music_enabled")), "options screen persists enabled music")
		_assert(bool(_profile.call("sfx_enabled")), "options screen persists enabled SFX")
		_assert(int(_profile.call("music_volume")) == 55, "options screen persists music volume")
		_assert(int(_profile.call("sfx_volume")) == 65, "options screen persists SFX volume")
		_assert(bool(_profile.call("bonus_stack_visible")), "options screen persists bonus-stack setting")
		_assert(bool(_profile.call("ball_tracks_visible")), "options screen persists ball-track setting")
		_assert(not bool(_profile.call("fps_visible")), "options screen persists FPS setting")
		_assert(bool(_profile.call("background_movable")), "options screen persists background-movable setting")
		_assert(int(_profile.call("background_type")) == 2, "options screen persists background type")
	if _audio != null:
		_assert(bool(_audio.call("music_enabled")), "options screen syncs audio music enabled")
		_assert(bool(_audio.call("sfx_enabled")), "options screen syncs audio SFX enabled")
		_assert(int(_audio.call("music_volume")) == 55, "options screen syncs audio music volume")
		_assert(int(_audio.call("sfx_volume")) == 65, "options screen syncs audio SFX volume")
	options_screen.queue_free()

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

	if _profile != null and _profile.has_method("set_save_path"):
		_profile.call("set_save_path", _test_profile_path("game_scene"), false)
	if _profile != null and _profile.has_method("record_score"):
		_assert(bool(_profile.call("record_score", 885)), "test profile accepts seeded high score")
	if _profile != null and _profile.has_method("set_bonus_stack_visible"):
		_profile.call("set_bonus_stack_visible", false)
		_profile.call("set_ball_tracks_visible", false)
		_profile.call("set_fps_visible", true)
		_profile.call("set_background_movable", false)
		_profile.call("set_background_type", 1)

	var game := GameScreenScene.instantiate()
	_assert(game.has_signal("game_over_confirmed"), "game screen exposes game-over confirmation signal")
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
			_assert(game.find_child("ImpactEffectRenderer", true, false) != null, "game screen creates impact effect renderer")
			_assert(game.call("is_bonus_stack_visible") == false, "game screen loads bonus-stack visibility setting")
			_assert(game.call("are_ball_tracks_visible") == false, "game screen loads ball-track visibility setting")
			_assert(game.call("is_fps_visible"), "game screen loads FPS visibility setting")
			_assert(game.call("current_background_type") == 1, "game screen loads background type setting")
			_assert(game.call("is_background_movable") == false, "game screen loads background movable setting")
			var game_bonus_renderer := game.find_child("BonusRenderer", true, false)
			if game_bonus_renderer != null:
				_assert(not game_bonus_renderer.call("is_stack_visible"), "bonus renderer applies hidden stack setting")
			var game_ball_renderer := game.find_child("BallRenderer", true, false)
			if game_ball_renderer != null:
				_assert(not game_ball_renderer.call("are_tracks_visible"), "ball renderer applies hidden tracks setting")
			_assert(playfield.background_type == 1, "playfield applies loaded background type")
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
			gameplay.award_score(1000)
			game.call("_process", 0.0)
			if _profile != null and _profile.has_method("best_score"):
				_assert(int(_profile.call("best_score")) == 1000, "game screen records new persisted high score")
			game.call("move_racket_to", 10000.0)
			_assert(gameplay.racket_rect().end.y == GameSessionScript.RACKET_MAX_BOTTOM, "game screen routes racket movement")
			game.call("_input", _action_event(GameScreenScript.ACTION_LAUNCH_BALL))
			await process_frame
			_assert(gameplay.state == GameSessionScript.STATE_PLAYING, "game screen launch enters playing state")
			_stack_bonus(gameplay, GameSessionScript.BONUS_EXTRA_LIFE)
			game.call("_input", _action_event(GameScreenScript.ACTION_USE_BONUS))
			await process_frame
			_assert(gameplay.lives_remaining == GameSessionScript.INITIAL_LIVES + 1, "game screen routes use-bonus action to bonus activation")
			game.call("_input", _action_event(GameScreenScript.ACTION_TOGGLE_BONUS_STACK))
			await process_frame
			_assert(game.call("is_bonus_stack_visible"), "game screen routes bonus-stack toggle")
			if _profile != null and _profile.has_method("bonus_stack_visible"):
				_assert(bool(_profile.call("bonus_stack_visible")), "bonus-stack toggle persists to profile")
			game.call("_input", _action_event(GameScreenScript.ACTION_TOGGLE_BALL_TRACKS))
			await process_frame
			_assert(game.call("are_ball_tracks_visible"), "game screen routes ball-track toggle")
			game.call("_input", _action_event(GameScreenScript.ACTION_TOGGLE_FPS))
			await process_frame
			_assert(not game.call("is_fps_visible"), "game screen routes FPS toggle")
			game.call("_input", _action_event(GameScreenScript.ACTION_CYCLE_BACKGROUND))
			await process_frame
			_assert(game.call("current_background_type") == 2, "game screen routes background-cycle action")
			_assert(playfield.background_type == 2, "background-cycle action updates playfield")
			game.call("_input", _action_event(GameScreenScript.ACTION_PAUSE))
			await process_frame
			_assert(game.call("is_game_paused"), "game screen routes pause action")
			var hourglass_cursor := game.find_child("HourglassCursorOverlay", true, false)
			_assert(hourglass_cursor != null and bool(hourglass_cursor.call("is_cursor_visible")), "game screen shows original hourglass cursor on pause")
			if hourglass_cursor != null:
				var paused_ball_position: Vector2 = gameplay.call("first_ball_position")
				var hourglass_frame := int(hourglass_cursor.call("current_frame_index"))
				game.call("_process", 0.12)
				_assert(gameplay.call("first_ball_position") == paused_ball_position, "pause freezes gameplay movement")
				_assert(int(hourglass_cursor.call("current_frame_index")) != hourglass_frame, "pause hourglass cursor animates")
			game.call("_input", _action_event(GameScreenScript.ACTION_TERMINATE_GAME))
			await process_frame
			_assert(game.call("is_exit_confirmation_visible"), "Escape opens leave-board confirmation while paused")
			var confirmation_prompt := game.find_child("ExitConfirmationPrompt", true, false) as Label
			_assert(confirmation_prompt != null and confirmation_prompt.visible, "game screen shows leave-board prompt")
			if confirmation_prompt != null:
				_assert(confirmation_prompt.text == "Are You sure to leave\nthis board (Y / N)", "leave-board prompt uses original text")
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
				var exit_game_over_title := hud.find_child("GameOverTitle", true, false) as Label
				var exit_game_over_summary := hud.find_child("GameOverSummary", true, false) as Label
				_assert(exit_game_over_title != null and exit_game_over_title.visible, "confirmed leave-board route shows game-over title before name entry")
				_assert(exit_game_over_summary != null and exit_game_over_summary.text == "Your Level #%d, and Score %d" % [int(gameplay.display_level_number), int(gameplay.score)], "confirmed leave-board route shows game-over summary before name entry")
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
			if hud != null:
				gameplay.state = GameSessionScript.STATE_GAME_OVER
				gameplay.lives_remaining = -1
				gameplay.score = 45
				gameplay.display_level_number = 3
				hud.call("refresh")
				var game_over_title := hud.find_child("GameOverTitle", true, false) as Label
				var game_over_summary := hud.find_child("GameOverSummary", true, false) as Label
				_assert(game_over_title != null and game_over_title.visible, "game hud shows game over title")
				_assert(game_over_summary != null and game_over_summary.text == "Your Level #3, and Score 45", "game hud shows game over run summary")
	game.queue_free()

	if _profile != null and _profile.has_method("set_music_enabled"):
		_profile.call("set_music_enabled", false)
	if _audio != null and _audio.has_method("apply_profile_settings"):
		_audio.call("apply_profile_settings")

	var app := AppScene.instantiate()
	root.add_child(app)
	await process_frame

	var app_menu := app.find_child("MainMenuScreen", true, false)
	_assert(app_menu != null, "app starts on main menu screen")
	if _audio != null and _audio.has_method("current_music_context"):
		_assert(String(_audio.call("current_music_context")) == AudioCueCatalogScript.CONTEXT_MAIN_MENU, "app starts main-menu music context")
		_assert(String(_audio.call("current_music_name")) == "Abnormal", "app starts original main-menu music")
	if app_menu != null:
		app_menu.emit_signal("rules_requested")
		await process_frame
		var app_rules := app.find_child("RulesScreen", true, false)
		_assert(app_rules != null, "app switches from menu to rules screen")
		if _audio != null and _audio.has_method("current_music_context"):
			_assert(String(_audio.call("current_music_context")) == AudioCueCatalogScript.CONTEXT_RULES, "rules screen uses rules music context")
			_assert(String(_audio.call("current_music_name")) == "Abnormal", "rules screen keeps original main-menu music")
		if app_rules != null:
			app_rules.emit_signal("back_requested")
			await process_frame
		app_menu = app.find_child("MainMenuScreen", true, false)
		_assert(app_menu != null, "app returns from rules screen to main menu")
		if _audio != null and _audio.has_method("current_music_context"):
			_assert(String(_audio.call("current_music_context")) == AudioCueCatalogScript.CONTEXT_MAIN_MENU, "rules back restores main-menu music context")

	if app_menu != null:
		app_menu.emit_signal("high_score_requested")
		await process_frame
		var app_high_score := app.find_child("HighScoreScreen", true, false)
		_assert(app_high_score != null, "app switches from menu to high-score screen")
		if _audio != null and _audio.has_method("current_music_context"):
			_assert(String(_audio.call("current_music_context")) == AudioCueCatalogScript.CONTEXT_HIGH_SCORE, "high-score screen uses high-score music context")
			_assert(String(_audio.call("current_music_name")) == "theme2", "high-score screen uses original theme2 music")
		if app_high_score != null:
			app_high_score.emit_signal("back_requested")
			await process_frame
		app_menu = app.find_child("MainMenuScreen", true, false)
		_assert(app_menu != null, "app returns from high-score screen to main menu")

	if app_menu != null:
		app_menu.emit_signal("options_requested")
		await process_frame
		var app_options := app.find_child("OptionsScreen", true, false)
		_assert(app_options != null, "app switches from menu to options screen")
		if _audio != null and _audio.has_method("current_music_context"):
			_assert(String(_audio.call("current_music_context")) == AudioCueCatalogScript.CONTEXT_OPTIONS, "options screen uses options music context")
			_assert(String(_audio.call("current_music_name")) == "Abnormal", "options screen keeps original main-menu music")
		if app_options != null:
			app_options.emit_signal("back_requested")
			await process_frame
		app_menu = app.find_child("MainMenuScreen", true, false)
		_assert(app_menu != null, "app returns from options screen to main menu")

	if app_menu != null:
		app_menu.emit_signal("credits_requested")
		await process_frame
		var app_credits := app.find_child("CreditsScreen", true, false)
		_assert(app_credits != null, "app switches from menu to credits screen")
		if _audio != null and _audio.has_method("current_music_context"):
			_assert(String(_audio.call("current_music_context")) == AudioCueCatalogScript.CONTEXT_CREDITS, "credits screen uses credits music context")
			_assert(String(_audio.call("current_music_name")) == "theme5", "credits screen uses original theme5 music")
		if app_credits != null:
			app_credits.emit_signal("back_requested")
			await process_frame
		app_menu = app.find_child("MainMenuScreen", true, false)
		_assert(app_menu != null, "app returns from credits screen to main menu")

	if app_menu != null:
		app_menu.emit_signal("start_game_requested")
		await process_frame
		var app_episode_select := app.find_child("EpisodeSelectScreen", true, false)
		_assert(app_episode_select != null, "app switches from menu to episode select screen")
		if _audio != null and _audio.has_method("current_music_context"):
			_assert(String(_audio.call("current_music_context")) == AudioCueCatalogScript.CONTEXT_EPISODE_SELECT, "episode select uses episode-select music context")
			_assert(String(_audio.call("current_music_name")) == "theme1", "episode select uses original theme1 music")
		if app_episode_select != null:
			app_episode_select.emit_signal("episode_selected", "Retro", 1)
			await process_frame
			var app_game := app.find_child("GameScreen", true, false)
			_assert(app_game != null, "app switches from episode select to game screen")
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
						if _audio != null and _audio.has_method("current_music_context"):
							_assert(String(_audio.call("current_music_context")) == AudioCueCatalogScript.CONTEXT_HIGH_SCORE, "score submission routes to high-score music context")
						var routed_high_score := app.find_child("HighScoreScreen", true, false)
						if routed_high_score != null:
							routed_high_score.emit_signal("back_requested")
							await process_frame
				await process_frame
				_assert(app.find_child("MainMenuScreen", true, false) != null, "app returns from submitted high-score table to main menu")
				if _audio != null and _audio.has_method("current_music_context"):
					_assert(String(_audio.call("current_music_context")) == AudioCueCatalogScript.CONTEXT_MAIN_MENU, "high-score back restores main-menu music context")
					_assert(String(_audio.call("current_music_name")) == "Abnormal", "high-score back restores original main-menu music")

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
					var exit_game_over_title := exit_game_hud.find_child("GameOverTitle", true, false) as Label
					_assert(exit_game_over_title != null and exit_game_over_title.visible, "app confirmed leave-board route shows game-over summary before name entry")
				exit_game.call("_input", _action_event(GameScreenScript.ACTION_LAUNCH_BALL))
				await process_frame
				var exit_name_entry := app.find_child("NameEntryScreen", true, false)
				_assert(exit_name_entry != null, "mouse-confirmed leave-board game-over summary routes to name entry")
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
					if _audio != null and _audio.has_method("current_music_context"):
						_assert(String(_audio.call("current_music_context")) == AudioCueCatalogScript.CONTEXT_HIGH_SCORE, "confirmed leave-board submission uses high-score music context")
	app.queue_free()
	await process_frame


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


func _key_event(keycode: Key, unicode := 0) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.unicode = unicode
	event.pressed = true
	return event


func _action_has_key(action_name: String, keycode: Key, ctrl_pressed := false) -> bool:
	for event: InputEvent in InputMap.action_get_events(action_name):
		var key_event := event as InputEventKey
		if key_event == null:
			continue
		var matches_key := key_event.keycode == keycode or key_event.physical_keycode == keycode
		if matches_key and key_event.ctrl_pressed == ctrl_pressed:
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


func _shutdown_test_audio() -> void:
	if _audio != null and _audio.has_method("stop_all"):
		_audio.call("stop_all", true)


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
