extends "res://src/menu/static_menu_screen.gd"
class_name CreditsScreen


func screen_title() -> String:
	return "Credits"


func body_lines() -> Array[String]:
	return [
		"Original game: 'WE' Group Krakout, version 1.93.",
		"Original release date from File_Id.diz: Jun 29, 2003.",
		"Reimplementation: Godot 4.6 project using extracted original assets.",
		"Runtime behavior remains grounded in the original executable and decoded data.",
	]
