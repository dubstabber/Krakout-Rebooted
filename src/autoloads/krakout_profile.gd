extends Node

const PlayfieldRendererScript := preload("res://src/playfield/playfield_renderer.gd")

const DEFAULT_SAVE_PATH := "user://krakout_profile.cfg"
const SCORES_SECTION := "scores"
const BEST_SCORE_KEY := "best_score"
const HIGH_SCORE_ENTRIES_KEY := "high_score_entries"
const SETTINGS_SECTION := "settings"
const BONUS_STACK_VISIBLE_KEY := "bonus_stack_visible"
const BALL_TRACKS_VISIBLE_KEY := "ball_tracks_visible"
const FPS_VISIBLE_KEY := "fps_visible"
const BACKGROUND_MOVABLE_KEY := "background_movable"
const BACKGROUND_TYPE_KEY := "background_type"
const FULLSCREEN_ENABLED_KEY := "fullscreen_enabled"
const MUSIC_ENABLED_KEY := "music_enabled"
const SFX_ENABLED_KEY := "sfx_enabled"
const MUSIC_VOLUME_KEY := "music_volume"
const SFX_VOLUME_KEY := "sfx_volume"
const DEFAULT_BONUS_STACK_VISIBLE := true
const DEFAULT_BALL_TRACKS_VISIBLE := true
const DEFAULT_FPS_VISIBLE := false
const DEFAULT_BACKGROUND_MOVABLE := true
const DEFAULT_BACKGROUND_TYPE := 2
const DEFAULT_FULLSCREEN_ENABLED := false
const DEFAULT_MUSIC_ENABLED := true
const DEFAULT_SFX_ENABLED := true
const DEFAULT_MUSIC_VOLUME := 80
const DEFAULT_SFX_VOLUME := 85
const HIGH_SCORE_TABLE_LIMIT := 10
const DEFAULT_PLAYER_NAME := "Anonymous"
const MAX_PLAYER_NAME_LENGTH := 20

@export var save_path := DEFAULT_SAVE_PATH

var _best_score := 0
var _high_score_entries: Array[Dictionary] = []
var _bonus_stack_visible := DEFAULT_BONUS_STACK_VISIBLE
var _ball_tracks_visible := DEFAULT_BALL_TRACKS_VISIBLE
var _fps_visible := DEFAULT_FPS_VISIBLE
var _background_movable := DEFAULT_BACKGROUND_MOVABLE
var _background_type := DEFAULT_BACKGROUND_TYPE
var _fullscreen_enabled := DEFAULT_FULLSCREEN_ENABLED
var _music_enabled := DEFAULT_MUSIC_ENABLED
var _sfx_enabled := DEFAULT_SFX_ENABLED
var _music_volume := DEFAULT_MUSIC_VOLUME
var _sfx_volume := DEFAULT_SFX_VOLUME
var _loaded := false


func _ready() -> void:
	load_profile()


func best_score() -> int:
	_ensure_loaded()
	return maxi(_best_score, _table_best_score())


func record_score(score_value: int) -> bool:
	return set_best_score(maxi(best_score(), score_value))


func set_best_score(score_value: int) -> bool:
	var normalized_score: int = maxi(0, score_value)
	_ensure_loaded()
	if _loaded and normalized_score <= _best_score:
		return false

	_best_score = normalized_score
	_loaded = true
	return save_profile()


func high_score_entries() -> Array[Dictionary]:
	_ensure_loaded()
	var entries := _duplicate_entries(_high_score_entries)
	if entries.is_empty() and _best_score > 0:
		entries.append(_high_score_entry(DEFAULT_PLAYER_NAME, _best_score, 1, ""))
	return entries


func would_enter_high_score(score_value: int) -> bool:
	_ensure_loaded()
	var normalized_score := maxi(0, score_value)
	if normalized_score <= 0:
		return false

	var entries := high_score_entries()
	if entries.size() < HIGH_SCORE_TABLE_LIMIT:
		return true

	var lowest_score := int(entries[entries.size() - 1].get("score", 0))
	return normalized_score > lowest_score


func submit_high_score(player_name: String, score_value: int, level_number: int, episode_slug: String) -> bool:
	_ensure_loaded()
	var normalized_score := maxi(0, score_value)
	if not would_enter_high_score(normalized_score):
		return false

	_materialize_legacy_best_if_needed(normalized_score)
	_high_score_entries.append(_high_score_entry(player_name, normalized_score, level_number, episode_slug))
	_sort_and_trim_high_scores()
	_best_score = maxi(_best_score, _table_best_score())
	return save_profile()


func bonus_stack_visible() -> bool:
	_ensure_loaded()
	return _bonus_stack_visible


func set_bonus_stack_visible(is_visible: bool) -> bool:
	_ensure_loaded()
	if _bonus_stack_visible == is_visible:
		return false
	_bonus_stack_visible = is_visible
	return save_profile()


func ball_tracks_visible() -> bool:
	_ensure_loaded()
	return _ball_tracks_visible


func set_ball_tracks_visible(is_visible: bool) -> bool:
	_ensure_loaded()
	if _ball_tracks_visible == is_visible:
		return false
	_ball_tracks_visible = is_visible
	return save_profile()


func fps_visible() -> bool:
	_ensure_loaded()
	return _fps_visible


func set_fps_visible(is_visible: bool) -> bool:
	_ensure_loaded()
	if _fps_visible == is_visible:
		return false
	_fps_visible = is_visible
	return save_profile()


func background_movable() -> bool:
	_ensure_loaded()
	return _background_movable


func set_background_movable(is_movable: bool) -> bool:
	_ensure_loaded()
	if _background_movable == is_movable:
		return false
	_background_movable = is_movable
	return save_profile()


func background_type() -> int:
	_ensure_loaded()
	return _background_type


func set_background_type(type_id: int) -> bool:
	_ensure_loaded()
	var normalized_type := PlayfieldRendererScript.normalize_background_type(type_id)
	if _background_type == normalized_type:
		return false
	_background_type = normalized_type
	return save_profile()


func fullscreen_enabled() -> bool:
	_ensure_loaded()
	return _fullscreen_enabled


func set_fullscreen_enabled(is_enabled: bool) -> bool:
	_ensure_loaded()
	if _fullscreen_enabled == is_enabled:
		return false
	_fullscreen_enabled = is_enabled
	return save_profile()


func music_enabled() -> bool:
	_ensure_loaded()
	return _music_enabled


func set_music_enabled(is_enabled: bool) -> bool:
	_ensure_loaded()
	if _music_enabled == is_enabled:
		return false
	_music_enabled = is_enabled
	return save_profile()


func sfx_enabled() -> bool:
	_ensure_loaded()
	return _sfx_enabled


func set_sfx_enabled(is_enabled: bool) -> bool:
	_ensure_loaded()
	if _sfx_enabled == is_enabled:
		return false
	_sfx_enabled = is_enabled
	return save_profile()


func music_volume() -> int:
	_ensure_loaded()
	return _music_volume


func set_music_volume(volume: int) -> bool:
	_ensure_loaded()
	var normalized_volume := clampi(volume, 0, 100)
	if _music_volume == normalized_volume:
		return false
	_music_volume = normalized_volume
	return save_profile()


func sfx_volume() -> int:
	_ensure_loaded()
	return _sfx_volume


func set_sfx_volume(volume: int) -> bool:
	_ensure_loaded()
	var normalized_volume := clampi(volume, 0, 100)
	if _sfx_volume == normalized_volume:
		return false
	_sfx_volume = normalized_volume
	return save_profile()


func load_profile() -> bool:
	_loaded = true
	_reset_profile_state()

	var config := ConfigFile.new()
	var error := config.load(save_path)
	if error == ERR_FILE_NOT_FOUND:
		return true
	if error != OK:
		push_warning("Unable to load Krakout profile: %s" % save_path)
		return false

	_best_score = maxi(0, int(config.get_value(SCORES_SECTION, BEST_SCORE_KEY, 0)))
	_high_score_entries = _entries_from_config(config.get_value(SCORES_SECTION, HIGH_SCORE_ENTRIES_KEY, ""))
	_bonus_stack_visible = bool(config.get_value(SETTINGS_SECTION, BONUS_STACK_VISIBLE_KEY, DEFAULT_BONUS_STACK_VISIBLE))
	_ball_tracks_visible = bool(config.get_value(SETTINGS_SECTION, BALL_TRACKS_VISIBLE_KEY, DEFAULT_BALL_TRACKS_VISIBLE))
	_fps_visible = bool(config.get_value(SETTINGS_SECTION, FPS_VISIBLE_KEY, DEFAULT_FPS_VISIBLE))
	_background_movable = bool(config.get_value(SETTINGS_SECTION, BACKGROUND_MOVABLE_KEY, DEFAULT_BACKGROUND_MOVABLE))
	_background_type = PlayfieldRendererScript.normalize_background_type(
		int(config.get_value(SETTINGS_SECTION, BACKGROUND_TYPE_KEY, DEFAULT_BACKGROUND_TYPE))
	)
	_fullscreen_enabled = bool(config.get_value(SETTINGS_SECTION, FULLSCREEN_ENABLED_KEY, DEFAULT_FULLSCREEN_ENABLED))
	_music_enabled = bool(config.get_value(SETTINGS_SECTION, MUSIC_ENABLED_KEY, DEFAULT_MUSIC_ENABLED))
	_sfx_enabled = bool(config.get_value(SETTINGS_SECTION, SFX_ENABLED_KEY, DEFAULT_SFX_ENABLED))
	_music_volume = clampi(int(config.get_value(SETTINGS_SECTION, MUSIC_VOLUME_KEY, DEFAULT_MUSIC_VOLUME)), 0, 100)
	_sfx_volume = clampi(int(config.get_value(SETTINGS_SECTION, SFX_VOLUME_KEY, DEFAULT_SFX_VOLUME)), 0, 100)
	return true


func save_profile() -> bool:
	var config := ConfigFile.new()
	_best_score = best_score()
	config.set_value(SCORES_SECTION, BEST_SCORE_KEY, _best_score)
	config.set_value(SCORES_SECTION, HIGH_SCORE_ENTRIES_KEY, JSON.stringify(_high_score_entries))
	config.set_value(SETTINGS_SECTION, BONUS_STACK_VISIBLE_KEY, _bonus_stack_visible)
	config.set_value(SETTINGS_SECTION, BALL_TRACKS_VISIBLE_KEY, _ball_tracks_visible)
	config.set_value(SETTINGS_SECTION, FPS_VISIBLE_KEY, _fps_visible)
	config.set_value(SETTINGS_SECTION, BACKGROUND_MOVABLE_KEY, _background_movable)
	config.set_value(SETTINGS_SECTION, BACKGROUND_TYPE_KEY, _background_type)
	config.set_value(SETTINGS_SECTION, FULLSCREEN_ENABLED_KEY, _fullscreen_enabled)
	config.set_value(SETTINGS_SECTION, MUSIC_ENABLED_KEY, _music_enabled)
	config.set_value(SETTINGS_SECTION, SFX_ENABLED_KEY, _sfx_enabled)
	config.set_value(SETTINGS_SECTION, MUSIC_VOLUME_KEY, _music_volume)
	config.set_value(SETTINGS_SECTION, SFX_VOLUME_KEY, _sfx_volume)
	var error := config.save(save_path)
	if error != OK:
		push_warning("Unable to save Krakout profile: %s" % save_path)
		return false
	return true


func set_save_path(path: String, load_existing := true) -> void:
	save_path = path
	_loaded = false
	_reset_profile_state()
	if load_existing:
		load_profile()


func _ensure_loaded() -> void:
	if not _loaded:
		load_profile()


func _reset_profile_state() -> void:
	_best_score = 0
	_high_score_entries.clear()
	_bonus_stack_visible = DEFAULT_BONUS_STACK_VISIBLE
	_ball_tracks_visible = DEFAULT_BALL_TRACKS_VISIBLE
	_fps_visible = DEFAULT_FPS_VISIBLE
	_background_movable = DEFAULT_BACKGROUND_MOVABLE
	_background_type = DEFAULT_BACKGROUND_TYPE
	_fullscreen_enabled = DEFAULT_FULLSCREEN_ENABLED
	_music_enabled = DEFAULT_MUSIC_ENABLED
	_sfx_enabled = DEFAULT_SFX_ENABLED
	_music_volume = DEFAULT_MUSIC_VOLUME
	_sfx_volume = DEFAULT_SFX_VOLUME


func _entries_from_config(raw_value: Variant) -> Array[Dictionary]:
	var parsed_entries: Variant
	if raw_value is String:
		var raw_text := String(raw_value)
		if raw_text.is_empty():
			return []
		parsed_entries = JSON.parse_string(raw_text)
	else:
		parsed_entries = raw_value

	var entries: Array[Dictionary] = []
	if parsed_entries is Array:
		for value: Variant in parsed_entries:
			if value is Dictionary:
				entries.append(_high_score_entry(
					String(value.get("name", DEFAULT_PLAYER_NAME)),
					int(value.get("score", 0)),
					int(value.get("level", 1)),
					String(value.get("episode", ""))
				))
	_sort_entries(entries)
	if entries.size() > HIGH_SCORE_TABLE_LIMIT:
		entries.resize(HIGH_SCORE_TABLE_LIMIT)
	return entries


func _materialize_legacy_best_if_needed(score_value: int) -> void:
	if not _high_score_entries.is_empty():
		return
	if _best_score <= score_value:
		return
	_high_score_entries.append(_high_score_entry(DEFAULT_PLAYER_NAME, _best_score, 1, ""))


func _high_score_entry(player_name: String, score_value: int, level_number: int, episode_slug: String) -> Dictionary:
	return {
		"name": _normalized_player_name(player_name),
		"score": maxi(0, score_value),
		"level": maxi(1, level_number),
		"episode": episode_slug,
	}


func _normalized_player_name(player_name: String) -> String:
	var normalized_name := player_name.strip_edges().replace("\n", " ").replace("\r", " ")
	while normalized_name.contains("  "):
		normalized_name = normalized_name.replace("  ", " ")
	if normalized_name.is_empty():
		normalized_name = DEFAULT_PLAYER_NAME
	if normalized_name.length() > MAX_PLAYER_NAME_LENGTH:
		normalized_name = normalized_name.substr(0, MAX_PLAYER_NAME_LENGTH)
	return normalized_name


func _sort_and_trim_high_scores() -> void:
	_sort_entries(_high_score_entries)
	if _high_score_entries.size() > HIGH_SCORE_TABLE_LIMIT:
		_high_score_entries.resize(HIGH_SCORE_TABLE_LIMIT)


func _sort_entries(entries: Array[Dictionary]) -> void:
	var indexed_entries: Array[Dictionary] = []
	for index in range(entries.size()):
		var entry := entries[index].duplicate()
		entry["_order"] = index
		indexed_entries.append(entry)

	indexed_entries.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		var left_score := int(left.get("score", 0))
		var right_score := int(right.get("score", 0))
		if left_score == right_score:
			return int(left.get("_order", 0)) < int(right.get("_order", 0))
		return left_score > right_score
	)

	entries.clear()
	for entry: Dictionary in indexed_entries:
		entry.erase("_order")
		entries.append(entry)


func _duplicate_entries(entries: Array[Dictionary]) -> Array[Dictionary]:
	var duplicates: Array[Dictionary] = []
	for entry: Dictionary in entries:
		duplicates.append(entry.duplicate())
	return duplicates


func _table_best_score() -> int:
	if _high_score_entries.is_empty():
		return 0
	return int(_high_score_entries[0].get("score", 0))
