extends RefCounted
class_name KrakoutHighScoreFile

const ENTRY_COUNT := 10
const NAME_BYTES := 100
const EPISODE_BYTES := 100
const LEVEL_OFFSET := 200
const SCORE_OFFSET := 204
const ENTRY_BYTES := 208
const FILE_BYTES := ENTRY_COUNT * ENTRY_BYTES
const FIELD_TEXT_BYTES := 99


static func load_entries(path: String) -> Array[Dictionary]:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return []

	var encoded_bytes := file.get_buffer(file.get_length())
	if encoded_bytes.size() != FILE_BYTES:
		return []
	return decode_entries(encoded_bytes)


static func save_entries(path: String, entries: Array) -> bool:
	if path.is_empty():
		return false

	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false

	file.store_buffer(encode_entries(entries))
	return true


static func decode_entries(encoded_bytes: PackedByteArray) -> Array[Dictionary]:
	if encoded_bytes.size() != FILE_BYTES:
		return []

	var decoded_bytes := _xor_by_byte_index(encoded_bytes)
	var entries: Array[Dictionary] = []
	for index in range(ENTRY_COUNT):
		var offset := index * ENTRY_BYTES
		var score := _read_u32_le(decoded_bytes, offset + SCORE_OFFSET)
		if score <= 0:
			continue

		var player_name := _read_c_string(decoded_bytes, offset, NAME_BYTES)
		var episode_slug := _read_c_string(decoded_bytes, offset + NAME_BYTES, EPISODE_BYTES)
		entries.append({
			"name": player_name,
			"score": score,
			"level": maxi(1, _read_u32_le(decoded_bytes, offset + LEVEL_OFFSET)),
			"episode": episode_slug,
		})
	return _normalized_entries(entries)


static func encode_entries(entries: Array) -> PackedByteArray:
	var decoded_bytes := PackedByteArray()
	decoded_bytes.resize(FILE_BYTES)

	var normalized_entries := _normalized_entries(entries)
	for index in range(mini(ENTRY_COUNT, normalized_entries.size())):
		var entry: Dictionary = normalized_entries[index]
		var offset := index * ENTRY_BYTES
		_write_c_string(decoded_bytes, offset, NAME_BYTES, String(entry.get("name", "")))
		_write_c_string(decoded_bytes, offset + NAME_BYTES, EPISODE_BYTES, String(entry.get("episode", "")))
		_write_u32_le(decoded_bytes, offset + LEVEL_OFFSET, int(entry.get("level", 1)))
		_write_u32_le(decoded_bytes, offset + SCORE_OFFSET, int(entry.get("score", 0)))
	return _xor_by_byte_index(decoded_bytes)


static func _xor_by_byte_index(bytes: PackedByteArray) -> PackedByteArray:
	var result := PackedByteArray()
	result.resize(bytes.size())
	for index in range(bytes.size()):
		result[index] = int(bytes[index]) ^ (index & 0xff)
	return result


static func _read_c_string(bytes: PackedByteArray, offset: int, byte_count: int) -> String:
	var string_bytes := PackedByteArray()
	for index in range(byte_count):
		var byte_value := int(bytes[offset + index])
		if byte_value == 0:
			break
		string_bytes.append(byte_value)
	return string_bytes.get_string_from_ascii().strip_edges()


static func _write_c_string(bytes: PackedByteArray, offset: int, byte_count: int, value: String) -> void:
	var string_bytes := value.strip_edges().to_ascii_buffer()
	var limit := mini(mini(byte_count - 1, string_bytes.size()), FIELD_TEXT_BYTES)
	for index in range(limit):
		bytes[offset + index] = int(string_bytes[index])


static func _read_u32_le(bytes: PackedByteArray, offset: int) -> int:
	return int(bytes[offset]) \
		| (int(bytes[offset + 1]) << 8) \
		| (int(bytes[offset + 2]) << 16) \
		| (int(bytes[offset + 3]) << 24)


static func _write_u32_le(bytes: PackedByteArray, offset: int, value: int) -> void:
	var normalized_value := maxi(0, value)
	bytes[offset] = normalized_value & 0xff
	bytes[offset + 1] = (normalized_value >> 8) & 0xff
	bytes[offset + 2] = (normalized_value >> 16) & 0xff
	bytes[offset + 3] = (normalized_value >> 24) & 0xff


static func _normalized_entries(entries: Array) -> Array[Dictionary]:
	var normalized: Array[Dictionary] = []
	for value: Variant in entries:
		if not value is Dictionary:
			continue
		var entry := value as Dictionary
		var score := maxi(0, int(entry.get("score", 0)))
		if score <= 0:
			continue
		normalized.append({
			"name": String(entry.get("name", "")),
			"score": score,
			"level": maxi(1, int(entry.get("level", 1))),
			"episode": String(entry.get("episode", "")),
		})

	var indexed_entries: Array[Dictionary] = []
	for index in range(normalized.size()):
		var entry := normalized[index].duplicate()
		entry["_order"] = index
		indexed_entries.append(entry)

	indexed_entries.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		var left_score := int(left.get("score", 0))
		var right_score := int(right.get("score", 0))
		if left_score == right_score:
			return int(left.get("_order", 0)) < int(right.get("_order", 0))
		return left_score > right_score
	)

	var trimmed: Array[Dictionary] = []
	for index in range(mini(ENTRY_COUNT, indexed_entries.size())):
		var entry := indexed_entries[index]
		entry.erase("_order")
		trimmed.append(entry)
	return trimmed
