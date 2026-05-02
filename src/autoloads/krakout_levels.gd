extends Node

const KrakoutLevelDataScript := preload("res://src/data/krakout_level_data.gd")


func episode_slugs() -> Array[String]:
	var assets := _assets()
	if assets == null or not assets.has_method("episode_slugs"):
		return []

	var result: Array[String] = []
	for slug: String in assets.call("episode_slugs"):
		result.append(slug)
	return result


func episode_summaries() -> Array[Dictionary]:
	var assets := _assets()
	if assets == null or not assets.has_method("episode_summaries"):
		return []

	var result: Array[Dictionary] = []
	for summary: Dictionary in assets.call("episode_summaries"):
		result.append(summary.duplicate())
	return result


func level_path(episode_slug: String, level_number: int) -> String:
	var assets := _assets()
	if assets == null or not assets.has_method("level_path"):
		return ""

	return String(assets.call("level_path", episode_slug, level_number))


func level_numbers(episode_slug: String) -> Array[int]:
	var assets := _assets()
	if assets == null or not assets.has_method("level_numbers"):
		return []

	var result: Array[int] = []
	for level_number: int in assets.call("level_numbers", episode_slug):
		result.append(level_number)
	return result


func episode_level_count(episode_slug: String) -> int:
	var assets := _assets()
	if assets == null or not assets.has_method("episode_level_count"):
		return 0

	return int(assets.call("episode_level_count", episode_slug))


func wrapped_level_number(episode_slug: String, display_level_number: int) -> int:
	var assets := _assets()
	if assets == null or not assets.has_method("wrapped_level_number"):
		return 0

	return int(assets.call("wrapped_level_number", episode_slug, display_level_number))


func load_level(episode_slug: String, level_number: int):
	var path := level_path(episode_slug, level_number)
	if path.is_empty():
		push_error("Unknown Krakout level: %s/%03d" % [episode_slug, level_number])
		return null

	return load_level_from_path(path)


func load_wrapped_level(episode_slug: String, display_level_number: int):
	var source_level_number := wrapped_level_number(episode_slug, display_level_number)
	if source_level_number <= 0:
		push_error("Unknown Krakout episode for wrapped level: %s" % episode_slug)
		return null

	return load_level(episode_slug, source_level_number)


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


func _assets() -> Node:
	return get_node_or_null("/root/KrakoutAssets")
