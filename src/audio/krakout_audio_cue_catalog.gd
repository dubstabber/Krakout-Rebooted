extends RefCounted
class_name KrakoutAudioCueCatalog

const CONTEXT_MAIN_MENU := "main_menu"
const CONTEXT_RULES := "rules"
const CONTEXT_HIGH_SCORE := "high_score"
const CONTEXT_OPTIONS := "options"
const CONTEXT_CREDITS := "credits"
const CONTEXT_EPISODE_SELECT := "episode_select"
const CONTEXT_GAMEPLAY := "gameplay"
const CONTEXT_NAME_ENTRY := "name_entry"

const MUSIC_CONTEXTS := {
	CONTEXT_MAIN_MENU: "Abnormal",
	CONTEXT_RULES: "Abnormal",
	CONTEXT_HIGH_SCORE: "theme2",
	CONTEXT_OPTIONS: "Abnormal",
	CONTEXT_CREDITS: "theme5",
	CONTEXT_EPISODE_SELECT: "theme1",
	CONTEXT_GAMEPLAY: "theme4",
	CONTEXT_NAME_ENTRY: "theme3",
}


static func music_name_for_context(context_name: String) -> String:
	return String(MUSIC_CONTEXTS.get(context_name, ""))


static func has_music_context(context_name: String) -> bool:
	return MUSIC_CONTEXTS.has(context_name)


static func known_contexts() -> Array[String]:
	var contexts: Array[String] = []
	for context_name: String in MUSIC_CONTEXTS.keys():
		contexts.append(context_name)
	contexts.sort()
	return contexts

