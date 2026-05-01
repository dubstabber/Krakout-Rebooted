extends Node

const KrakoutLevelDataScript := preload("res://src/data/krakout_level_data.gd")


func episode_slugs() -> Array[String]:
	return KrakoutAssets.episode_slugs()


func level_path(episode_slug: String, level_number: int) -> String:
	return KrakoutAssets.level_path(episode_slug, level_number)


func load_level(episode_slug: String, level_number: int):
	var path := level_path(episode_slug, level_number)
	if path.is_empty():
		push_error("Unknown Krakout level: %s/%03d" % [episode_slug, level_number])
		return null

	return load_level_from_path(path)


func load_level_from_path(path: String):
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Unable to open Krakout level JSON: %s" % path)
		return null

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Krakout level JSON is not an object: %s" % path)
		return null

	return KrakoutLevelDataScript.from_dictionary(parsed, path)
