extends RefCounted
class_name KrakoutTransientVfxPool

const MAX_IMPACT_EFFECTS := 100
const IMPACT_EFFECT_FRAME_SECONDS := 0.05
const IMPACT_EFFECT_FRAME_COUNT := 11
const IMPACT_EFFECT_DURATION_SECONDS := IMPACT_EFFECT_FRAME_SECONDS * IMPACT_EFFECT_FRAME_COUNT
const MAX_SCORE_POPUPS := 40
const SCORE_POPUP_FRAME_COUNT := 15
const SCORE_POPUP_FRAME_SECONDS := 0.035
const SCORE_POPUP_STEP_SECONDS := 1.0 / 50.0
const SCORE_POPUP_STEP_PIXELS := 3.0
const SCORE_POPUP_MIN_Y := 10.0

var impact_effects: Array
var score_popups: Array


func _init(shared_impact_effects: Array, shared_score_popups: Array) -> void:
	impact_effects = shared_impact_effects
	score_popups = shared_score_popups


func visible_impact_effects() -> Array[Dictionary]:
	var visible: Array[Dictionary] = []
	for effect: Dictionary in impact_effects:
		if bool(effect.get("active", false)):
			visible.append(effect.duplicate())
	return visible


func visible_score_popups() -> Array[Dictionary]:
	var visible: Array[Dictionary] = []
	for popup: Dictionary in score_popups:
		if bool(popup.get("active", false)):
			visible.append(popup.duplicate())
	return visible


func update_impact_effects(delta: float) -> void:
	for index in range(impact_effects.size()):
		var effect: Dictionary = impact_effects[index]
		if not bool(effect.get("active", false)):
			continue

		var age := float(effect.get("age", 0.0)) + delta
		var frame_elapsed := float(effect.get("frame_elapsed", 0.0)) + delta
		var frame := int(effect.get("frame", 0))
		while frame_elapsed >= IMPACT_EFFECT_FRAME_SECONDS:
			frame = mini(frame + 1, IMPACT_EFFECT_FRAME_COUNT - 1)
			frame_elapsed -= IMPACT_EFFECT_FRAME_SECONDS
		effect["age"] = age
		effect["frame"] = frame
		effect["frame_elapsed"] = frame_elapsed
		if age >= IMPACT_EFFECT_DURATION_SECONDS:
			effect["active"] = false
		impact_effects[index] = effect

	compact_impact_effects()


func update_score_popups(delta: float) -> void:
	for index in range(score_popups.size()):
		var popup: Dictionary = score_popups[index]
		if not bool(popup.get("active", false)):
			continue

		var position: Vector2 = popup.get("position", Vector2.ZERO)
		var step_elapsed := float(popup.get("step_elapsed", 0.0)) + delta
		while step_elapsed >= SCORE_POPUP_STEP_SECONDS:
			step_elapsed -= SCORE_POPUP_STEP_SECONDS
			position.y -= SCORE_POPUP_STEP_PIXELS

		var frame_elapsed := float(popup.get("frame_elapsed", 0.0)) + delta
		var frame := int(popup.get("frame", 0))
		while frame_elapsed >= SCORE_POPUP_FRAME_SECONDS and bool(popup.get("active", false)):
			frame_elapsed -= SCORE_POPUP_FRAME_SECONDS
			frame += 1
			if frame >= SCORE_POPUP_FRAME_COUNT:
				popup["active"] = false
				frame = SCORE_POPUP_FRAME_COUNT - 1
				frame_elapsed = 0.0

		if position.y < SCORE_POPUP_MIN_Y:
			popup["active"] = false

		popup["position"] = position
		popup["step_elapsed"] = step_elapsed
		popup["frame"] = frame
		popup["frame_elapsed"] = frame_elapsed
		score_popups[index] = popup

	compact_score_popups()


func spawn_impact_effect(position: Vector2, kind: int) -> bool:
	compact_impact_effects()
	if impact_effects.size() >= MAX_IMPACT_EFFECTS:
		return false
	impact_effects.append({
		"active": true,
		"position": position,
		"kind": kind,
		"frame": 0,
		"frame_elapsed": 0.0,
		"age": 0.0,
	})
	return true


func spawn_score_popup(position: Vector2, value: int) -> bool:
	if value <= 0:
		return false

	compact_score_popups()
	if score_popups.size() >= MAX_SCORE_POPUPS:
		return false

	score_popups.append({
		"active": true,
		"position": position,
		"value": value,
		"frame": 0,
		"frame_elapsed": 0.0,
		"step_elapsed": 0.0,
	})
	return true


func compact_impact_effects() -> void:
	var compacted: Array[Dictionary] = []
	for effect: Dictionary in impact_effects:
		if bool(effect.get("active", false)):
			compacted.append(effect)
	impact_effects.clear()
	for effect: Dictionary in compacted:
		impact_effects.append(effect)


func compact_score_popups() -> void:
	var compacted: Array[Dictionary] = []
	for popup: Dictionary in score_popups:
		if bool(popup.get("active", false)):
			compacted.append(popup)
	score_popups.clear()
	for popup: Dictionary in compacted:
		score_popups.append(popup)


func clear_score_popups() -> void:
	score_popups.clear()
