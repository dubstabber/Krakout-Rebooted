extends Node

const DEFAULT_SAVE_PATH := "user://krakout_profile.cfg"
const SCORES_SECTION := "scores"
const BEST_SCORE_KEY := "best_score"

@export var save_path := DEFAULT_SAVE_PATH

var _best_score := 0
var _loaded := false


func _ready() -> void:
	load_profile()


func best_score() -> int:
	if not _loaded:
		load_profile()
	return _best_score


func record_score(score_value: int) -> bool:
	return set_best_score(maxi(best_score(), score_value))


func set_best_score(score_value: int) -> bool:
	var normalized_score: int = maxi(0, score_value)
	if _loaded and normalized_score <= _best_score:
		return false

	_best_score = normalized_score
	_loaded = true
	return save_profile()


func load_profile() -> bool:
	_loaded = true
	_best_score = 0

	var config := ConfigFile.new()
	var error := config.load(save_path)
	if error == ERR_FILE_NOT_FOUND:
		return true
	if error != OK:
		push_warning("Unable to load Krakout profile: %s" % save_path)
		return false

	_best_score = maxi(0, int(config.get_value(SCORES_SECTION, BEST_SCORE_KEY, 0)))
	return true


func save_profile() -> bool:
	var config := ConfigFile.new()
	config.set_value(SCORES_SECTION, BEST_SCORE_KEY, _best_score)
	var error := config.save(save_path)
	if error != OK:
		push_warning("Unable to save Krakout profile: %s" % save_path)
		return false
	return true


func set_save_path(path: String, load_existing := true) -> void:
	save_path = path
	_loaded = false
	_best_score = 0
	if load_existing:
		load_profile()
