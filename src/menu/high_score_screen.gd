extends "res://src/menu/static_menu_screen.gd"
class_name HighScoreScreen

const ProfileScript := preload("res://src/autoloads/krakout_profile.gd")

var _best_score := 0
var _entries: Array[Dictionary] = []


func _ready() -> void:
	refresh_from_profile()
	super()


func screen_title() -> String:
	return "High Score"


func body_lines() -> Array[String]:
	if _entries.is_empty():
		return [
			"Best Players Table",
			"No saved scores",
		]

	var lines: Array[String] = [
		"Best Players Table",
		"#  Players Name          Lev     Score",
	]
	for index in range(_entries.size()):
		var entry := _entries[index]
		lines.append("%2d  %-20s %3d %9d" % [
			index + 1,
			String(entry.get("name", ProfileScript.DEFAULT_PLAYER_NAME)).substr(0, ProfileScript.MAX_PLAYER_NAME_LENGTH),
			int(entry.get("level", 1)),
			int(entry.get("score", 0)),
		])
	return [
		"\n".join(lines),
	]


func best_score() -> int:
	return _best_score


func high_score_entries() -> Array[Dictionary]:
	var duplicates: Array[Dictionary] = []
	for entry: Dictionary in _entries:
		duplicates.append(entry.duplicate())
	return duplicates


func refresh_from_profile() -> void:
	_best_score = _profile_best_score()
	_entries = _profile_high_score_entries()
	refresh_content()


func _profile_best_score() -> int:
	var profile := get_node_or_null("/root/KrakoutProfile")
	if profile == null or not profile.has_method("best_score"):
		return 0
	return maxi(0, int(profile.call("best_score")))


func _profile_high_score_entries() -> Array[Dictionary]:
	var profile := get_node_or_null("/root/KrakoutProfile")
	if profile == null or not profile.has_method("high_score_entries"):
		return []

	var entries: Array[Dictionary] = []
	for entry: Dictionary in profile.call("high_score_entries"):
		entries.append(entry.duplicate())
	return entries
