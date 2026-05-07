extends "res://src/menu/static_menu_screen.gd"
class_name RulesScreen


func screen_title() -> String:
	return "Game Rules"


func body_lines() -> Array[String]:
	return [
		"Destroy every required brick",
		"while keeping the ball inside",
		"the playfield.",
		"Some bricks release original",
		"powerups for the paddle,",
		"balls, wall, and weapons.",
		"Collected powerups enter the",
		"stack and activate",
		"in order.",
		"Current rules stay limited to",
		"original-backed behavior.",
	]
