extends Node

const DEFAULT_SAVE_PATH := "user://krakout_profile.cfg"
const SCORES_SECTION := "scores"
const BEST_SCORE_KEY := "best_score"
const SETTINGS_SECTION := "settings"
const BONUS_STACK_VISIBLE_KEY := "bonus_stack_visible"
const BALL_TRACKS_VISIBLE_KEY := "ball_tracks_visible"
const FPS_VISIBLE_KEY := "fps_visible"
const BACKGROUND_MOVABLE_KEY := "background_movable"
const BACKGROUND_TYPE_KEY := "background_type"
const DEFAULT_BONUS_STACK_VISIBLE := true
const DEFAULT_BALL_TRACKS_VISIBLE := true
const DEFAULT_FPS_VISIBLE := false
const DEFAULT_BACKGROUND_MOVABLE := true
const DEFAULT_BACKGROUND_TYPE := 2

@export var save_path := DEFAULT_SAVE_PATH

var _best_score := 0
var _bonus_stack_visible := DEFAULT_BONUS_STACK_VISIBLE
var _ball_tracks_visible := DEFAULT_BALL_TRACKS_VISIBLE
var _fps_visible := DEFAULT_FPS_VISIBLE
var _background_movable := DEFAULT_BACKGROUND_MOVABLE
var _background_type := DEFAULT_BACKGROUND_TYPE
var _loaded := false


func _ready() -> void:
	load_profile()


func best_score() -> int:
	_ensure_loaded()
	return _best_score


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
	var normalized_type := maxi(0, type_id)
	if _background_type == normalized_type:
		return false
	_background_type = normalized_type
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
	_bonus_stack_visible = bool(config.get_value(SETTINGS_SECTION, BONUS_STACK_VISIBLE_KEY, DEFAULT_BONUS_STACK_VISIBLE))
	_ball_tracks_visible = bool(config.get_value(SETTINGS_SECTION, BALL_TRACKS_VISIBLE_KEY, DEFAULT_BALL_TRACKS_VISIBLE))
	_fps_visible = bool(config.get_value(SETTINGS_SECTION, FPS_VISIBLE_KEY, DEFAULT_FPS_VISIBLE))
	_background_movable = bool(config.get_value(SETTINGS_SECTION, BACKGROUND_MOVABLE_KEY, DEFAULT_BACKGROUND_MOVABLE))
	_background_type = maxi(0, int(config.get_value(SETTINGS_SECTION, BACKGROUND_TYPE_KEY, DEFAULT_BACKGROUND_TYPE)))
	return true


func save_profile() -> bool:
	var config := ConfigFile.new()
	config.set_value(SCORES_SECTION, BEST_SCORE_KEY, _best_score)
	config.set_value(SETTINGS_SECTION, BONUS_STACK_VISIBLE_KEY, _bonus_stack_visible)
	config.set_value(SETTINGS_SECTION, BALL_TRACKS_VISIBLE_KEY, _ball_tracks_visible)
	config.set_value(SETTINGS_SECTION, FPS_VISIBLE_KEY, _fps_visible)
	config.set_value(SETTINGS_SECTION, BACKGROUND_MOVABLE_KEY, _background_movable)
	config.set_value(SETTINGS_SECTION, BACKGROUND_TYPE_KEY, _background_type)
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
	_bonus_stack_visible = DEFAULT_BONUS_STACK_VISIBLE
	_ball_tracks_visible = DEFAULT_BALL_TRACKS_VISIBLE
	_fps_visible = DEFAULT_FPS_VISIBLE
	_background_movable = DEFAULT_BACKGROUND_MOVABLE
	_background_type = DEFAULT_BACKGROUND_TYPE
