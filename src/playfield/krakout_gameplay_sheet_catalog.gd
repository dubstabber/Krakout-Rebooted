extends RefCounted
class_name KrakoutGameplaySheetCatalog

const SHEETS := {
	"Backgr": {
		"texture_name": "Backgr",
		"expected_size": Vector2i(200, 100),
		"source": "IDA sub_40D650",
	},
	"Balls": {
		"texture_name": "Balls",
		"expected_size": Vector2i(440, 420),
		"source": "IDA sub_4011F0",
	},
	"Bee": {
		"texture_name": "Bee",
		"expected_size": Vector2i(48, 240),
		"source": "IDA sub_4194C0",
	},
	"Bonuses_a": {
		"texture_name": "Bonuses_a",
		"expected_size": Vector2i(704, 320),
		"source": "IDA sub_402BD0",
	},
	"Bonuses_aa": {
		"texture_name": "Bonuses_aa",
		"expected_size": Vector2i(704, 320),
		"source": "IDA sub_402BD0",
	},
	"Bricks": {
		"texture_name": "Bricks",
		"expected_size": Vector2i(100, 4830),
		"source": "IDA sub_40D650",
		"verified_frame_size": Vector2i(20, 30),
		"verified_columns": 5,
	},
	"Bullets": {
		"texture_name": "Bullets",
		"expected_size": Vector2i(200, 45),
		"source": "IDA sub_4033F0",
	},
	"Clock": {
		"texture_name": "Clock",
		"expected_size": Vector2i(100, 2000),
		"source": "IDA sub_40D650",
	},
	"Digits": {
		"texture_name": "Digits",
		"expected_size": Vector2i(16, 200),
		"source": "IDA sub_40D650",
	},
	"DigitsSmall": {
		"texture_name": "DigitsSmall",
		"expected_size": Vector2i(80, 180),
		"source": "IDA sub_40D650",
	},
	"Exploision": {
		"texture_name": "Exploision",
		"expected_size": Vector2i(192, 352),
		"source": "IDA sub_40B130",
	},
	"Fb": {
		"texture_name": "Fb",
		"expected_size": Vector2i(24, 144),
		"source": "IDA sub_4011F0",
	},
	"Font": {
		"texture_name": "Font",
		"expected_size": Vector2i(32, 2256),
		"source": "IDA sub_40D650",
	},
	"InfoIcons": {
		"texture_name": "InfoIcons",
		"expected_size": Vector2i(168, 28),
		"source": "IDA sub_40D650",
	},
	"Monsters": {
		"texture_name": "Monsters",
		"expected_size": Vector2i(352, 640),
		"source": "IDA sub_4194C0",
	},
	"PointToBonusInStack": {
		"texture_name": "PointToBonusInStack",
		"expected_size": Vector2i(32, 200),
		"source": "IDA sub_402BD0",
	},
	"Racket": {
		"texture_name": "Racket",
		"expected_size": Vector2i(227, 202),
		"source": "IDA sub_40D650",
	},
	"Roller": {
		"texture_name": "Roller",
		"expected_size": Vector2i(200, 390),
		"source": "IDA sub_40D650",
	},
	"Snake": {
		"texture_name": "Snake",
		"expected_size": Vector2i(50, 40),
		"source": "IDA sub_4194C0",
	},
	"Statistic": {
		"texture_name": "Statistic",
		"expected_size": Vector2i(640, 39),
		"source": "IDA sub_40D650",
	},
	"Walls": {
		"texture_name": "Walls",
		"expected_size": Vector2i(135, 72),
		"source": "IDA sub_40D650",
	},
}


static func sheet_names() -> Array[String]:
	var names: Array[String] = []
	for name: String in SHEETS.keys():
		names.append(name)
	names.sort()
	return names


static func has_sheet(sheet_name: String) -> bool:
	return SHEETS.has(sheet_name)


static func metadata_for(sheet_name: String) -> Dictionary:
	return SHEETS.get(sheet_name, {})


static func texture_name_for(sheet_name: String) -> String:
	var metadata := metadata_for(sheet_name)
	return String(metadata.get("texture_name", ""))


static func expected_size_for(sheet_name: String) -> Vector2i:
	var metadata := metadata_for(sheet_name)
	return metadata.get("expected_size", Vector2i.ZERO)


static func has_verified_frame_layout(sheet_name: String) -> bool:
	var metadata := metadata_for(sheet_name)
	return metadata.has("verified_frame_size") and int(metadata.get("verified_columns", 0)) > 0


static func verified_frame_rect_for(sheet_name: String, frame_index: int) -> Rect2:
	if not has_verified_frame_layout(sheet_name):
		return Rect2()

	var metadata := metadata_for(sheet_name)
	var frame_size: Vector2i = metadata.get("verified_frame_size", Vector2i.ZERO)
	var columns := int(metadata.get("verified_columns", 0))
	var safe_index: int = max(frame_index, 0)
	var source_column := safe_index % columns
	var source_row := int(safe_index / columns)
	return Rect2(
		Vector2(source_column * frame_size.x, source_row * frame_size.y),
		Vector2(frame_size)
	)
