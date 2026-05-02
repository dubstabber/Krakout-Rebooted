extends "res://src/menu/static_menu_screen.gd"
class_name HighScoreScreen

var _best_score := 0


func _ready() -> void:
	_best_score = _profile_best_score()
	super()


func screen_title() -> String:
	return "High Score"


func body_lines() -> Array[String]:
	return [
		"Best Score",
		str(_best_score),
	]


func best_score() -> int:
	return _best_score


func refresh_from_profile() -> void:
	_best_score = _profile_best_score()
	refresh_content()


func _profile_best_score() -> int:
	var profile := get_node_or_null("/root/KrakoutProfile")
	if profile == null or not profile.has_method("best_score"):
		return 0
	return maxi(0, int(profile.call("best_score")))
