extends RefCounted
class_name KrakoutAudioEventQueue

const GameplayStateScript := preload("res://src/gameplay/krakout_gameplay_state.gd")

const SFX_PAN_SOURCE_SCALE := 0.3125
const SFX_PAN_SOURCE_OFFSET := -100.0
const SFX_PAN_MIN := -100.0
const SFX_PAN_MAX := 100.0

var events: Array


func _init(shared_events) -> void:
	if shared_events is GameplayStateScript:
		events = shared_events.audio_events
	else:
		events = shared_events


static func sfx_pan100_for_source_x(source_x: float) -> float:
	return clampf(source_x * SFX_PAN_SOURCE_SCALE + SFX_PAN_SOURCE_OFFSET, SFX_PAN_MIN, SFX_PAN_MAX)


static func sfx_pan_for_source_x(source_x: float) -> float:
	return sfx_pan100_for_source_x(source_x) / SFX_PAN_MAX


func clear() -> void:
	events.clear()


func queue_event(event_name: String) -> void:
	queue_payload({"event": event_name})


func queue_event_at_x(event_name: String, source_x: float) -> void:
	queue_payload({
		"event": event_name,
		"source_x": source_x,
		"pan100": sfx_pan100_for_source_x(source_x),
	})


func queue_event_with_pan100(event_name: String, pan100: float) -> void:
	queue_payload({
		"event": event_name,
		"pan100": pan100,
	})


func queue_payload(event_payload: Dictionary) -> void:
	var event_name := String(event_payload.get("event", ""))
	if event_name.is_empty():
		return
	var normalized_payload := event_payload.duplicate(true)
	normalized_payload["event"] = event_name
	if normalized_payload.has("source_x") and not normalized_payload.has("pan100"):
		normalized_payload["pan100"] = sfx_pan100_for_source_x(float(normalized_payload["source_x"]))
	elif normalized_payload.has("pan100"):
		normalized_payload["pan100"] = clampf(float(normalized_payload["pan100"]), SFX_PAN_MIN, SFX_PAN_MAX)
	events.append(normalized_payload)


func pop_event_names() -> Array[String]:
	var names: Array[String] = []
	for event_payload: Dictionary in events:
		var event_name := String(event_payload.get("event", ""))
		if not event_name.is_empty():
			names.append(event_name)
	clear()
	return names


func pop_payloads() -> Array[Dictionary]:
	var payloads: Array[Dictionary] = []
	for event_payload: Dictionary in events:
		payloads.append(event_payload.duplicate(true))
	clear()
	return payloads
