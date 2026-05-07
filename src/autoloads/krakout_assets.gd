extends Node

const ASSET_ROOT := "res://assets/krakout"
const MANIFEST_PATH := ASSET_ROOT + "/manifest.json"

var manifest: Dictionary = {}
var _textures_by_name: Dictionary = {}
var _sfx_by_name: Dictionary = {}
var _music_by_name: Dictionary = {}
var _levels_by_episode: Dictionary = {}
var _episode_summaries: Array[Dictionary] = []
var _texture_cache: Dictionary = {}


func _ready() -> void:
	reload()


func reload() -> bool:
	var file := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if file == null:
		push_error("Unable to open Krakout asset manifest: %s" % MANIFEST_PATH)
		return false

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Krakout asset manifest is not a JSON object: %s" % MANIFEST_PATH)
		return false

	manifest = parsed
	_index_manifest()
	return true


func texture_count() -> int:
	return manifest.get("textures", []).size()


func sfx_count() -> int:
	return manifest.get("audio", {}).get("sfx", []).size()


func music_count() -> int:
	return manifest.get("audio", {}).get("music", []).size()


func level_count() -> int:
	var count := 0
	for levels: Dictionary in _levels_by_episode.values():
		count += levels.size()
	return count


func episode_slugs() -> Array[String]:
	var result: Array[String] = []
	for slug: String in _levels_by_episode.keys():
		result.append(slug)
	result.sort()
	return result


func episode_summaries() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for summary: Dictionary in _episode_summaries:
		result.append(summary.duplicate())
	return result


func texture_path(name: String) -> String:
	return _path_from_name(_textures_by_name, name, ".png")


func sfx_path(name: String) -> String:
	return _path_from_name(_sfx_by_name, name, ".wav")


func music_path(name: String) -> String:
	return _path_from_name(_music_by_name, name, ".ogg")


func level_path(episode_slug: String, level_number: int) -> String:
	if not _levels_by_episode.has(episode_slug):
		return ""

	var levels: Dictionary = _levels_by_episode[episode_slug]
	return String(levels.get(level_number, ""))


func level_numbers(episode_slug: String) -> Array[int]:
	var result: Array[int] = []
	if not _levels_by_episode.has(episode_slug):
		return result

	var levels: Dictionary = _levels_by_episode[episode_slug]
	for level_number: Variant in levels.keys():
		result.append(int(level_number))
	result.sort()
	return result


func episode_level_count(episode_slug: String) -> int:
	return level_numbers(episode_slug).size()


func wrapped_level_number(episode_slug: String, display_level_number: int) -> int:
	var numbers: Array[int] = level_numbers(episode_slug)
	if numbers.is_empty():
		return 0

	var zero_based_index: int = max(0, display_level_number - 1)
	return numbers[zero_based_index % numbers.size()]


func load_texture(name: String) -> Texture2D:
	if _texture_cache.has(name):
		return _texture_cache[name] as Texture2D

	var path := texture_path(name)
	if path.is_empty():
		push_error("Unknown Krakout texture: %s" % name)
		return null

	var texture := load(path) as Texture2D
	if texture == null:
		return null

	texture = _apply_runtime_texture_processing(name, texture)
	_texture_cache[name] = texture
	return texture


func _index_manifest() -> void:
	_textures_by_name.clear()
	_sfx_by_name.clear()
	_music_by_name.clear()
	_levels_by_episode.clear()
	_episode_summaries.clear()
	_texture_cache.clear()

	for texture_entry: Dictionary in manifest.get("textures", []):
		_index_named_path(_textures_by_name, String(texture_entry.get("output_path", "")))

	for sfx_entry: Dictionary in manifest.get("audio", {}).get("sfx", []):
		_index_named_path(_sfx_by_name, String(sfx_entry.get("output_path", "")))

	for music_entry: Dictionary in manifest.get("audio", {}).get("music", []):
		_index_named_path(_music_by_name, String(music_entry.get("output_path", "")))

	var episode_metadata: Dictionary = {}
	for level_entry: Dictionary in manifest.get("levels", []):
		var path := String(level_entry.get("output_path", ""))
		if path.is_empty():
			continue

		var episode_slug := path.get_base_dir().get_file()
		var level_number := int(level_entry.get("level_number", 0))
		if episode_slug.is_empty() or level_number <= 0:
			continue

		if not _levels_by_episode.has(episode_slug):
			_levels_by_episode[episode_slug] = {}
		_levels_by_episode[episode_slug][level_number] = path

		if not episode_metadata.has(episode_slug):
			episode_metadata[episode_slug] = {
				"slug": episode_slug,
				"title": String(level_entry.get("episode_title", episode_slug)),
				"level_count": 0,
				"first_level_number": level_number,
			}

		var summary: Dictionary = episode_metadata[episode_slug]
		summary["level_count"] = int(summary["level_count"]) + 1
		summary["first_level_number"] = min(int(summary["first_level_number"]), level_number)

	for summary: Dictionary in episode_metadata.values():
		_episode_summaries.append(summary)
	_episode_summaries.sort_custom(_compare_episode_summaries)


func _index_named_path(index: Dictionary, path: String) -> void:
	if path.is_empty():
		return

	var file_name := path.get_file()
	var base_name := file_name.get_basename()
	index[file_name] = path
	index[base_name] = path


func _path_from_name(index: Dictionary, name: String, default_extension: String) -> String:
	if index.has(name):
		return String(index[name])

	if not name.ends_with(default_extension) and index.has(name + default_extension):
		return String(index[name + default_extension])

	return ""


func _apply_runtime_texture_processing(name: String, texture: Texture2D) -> Texture2D:
	if name == "Arrowup" or name == "Arrowdown":
		return _black_to_transparent_texture(texture)
	return texture


func _black_to_transparent_texture(texture: Texture2D) -> Texture2D:
	var image := texture.get_image()
	if image == null:
		return texture

	image.convert(Image.FORMAT_RGBA8)
	var changed := false
	var width := image.get_width()
	var height := image.get_height()
	for y in range(height):
		for x in range(width):
			var color := image.get_pixel(x, y)
			if color.a > 0.0 and color.r == 0.0 and color.g == 0.0 and color.b == 0.0:
				color.a = 0.0
				image.set_pixel(x, y, color)
				changed = true

	if not changed:
		return texture

	return ImageTexture.create_from_image(image)


func _compare_episode_summaries(left: Dictionary, right: Dictionary) -> bool:
	var left_title := String(left.get("title", "")).to_lower()
	var right_title := String(right.get("title", "")).to_lower()
	if left_title == right_title:
		return String(left.get("slug", "")) < String(right.get("slug", ""))
	return left_title < right_title
