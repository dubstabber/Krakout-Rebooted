extends "res://src/menu/static_menu_screen.gd"
class_name CreditsScreen


func screen_title() -> String:
	return "Credits"


func body_lines() -> Array[String]:
	return [
		"Original game:",
		"'WE' Group Krakout v1.93.",
		"Release date:",
		"Jun 29, 2003.",
		"Reimplementation:",
		"Godot 4.6 using extracted",
		"original assets.",
		"Behavior stays grounded in",
		"the original executable",
		"and decoded data.",
	]
